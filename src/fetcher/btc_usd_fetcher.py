import os
import json
import logging
import websocket
import signal
from kafka import KafkaProducer
from time import sleep

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

class WebSocketKafkaConnector:
    def __init__(self):
        self.ws = None
        self.producer = None
        self.connect_to_kafka()

    def connect_to_kafka(self, retries=5, delay=1):
        for i in range(retries):
            try:
                logging.info("Connecting to Kafka...")
                self.producer = KafkaProducer(
                    bootstrap_servers=os.environ['MSK_BOOTSTRAP_SERVERS'].split(','),
                    security_protocol='SASL_SSL',
                    sasl_mechanism='SCRAM-SHA-512',
                    sasl_plain_username=os.environ['MSK_USERNAME'],
                    sasl_plain_password=os.environ['MSK_PASSWORD']
                )
                logging.info("Connected to Kafka.")
                return
            except Exception as e:
                logging.error(f"Failed to connect to Kafka: {e}. Retrying in {delay} seconds...")
                sleep(delay)
                delay *= 2  # Exponential backoff
        
        logging.critical("Exceeded maximum retries.")
        raise ConnectionError("Failed to connect to Kafka")

    def on_message(self, ws, message):
        if self.producer is None:
            logging.error("Kafka producer is not initialized")
            return

        try:
            data = json.loads(message)
            logging.debug(f"Raw WebSocket message: {message}")
            logging.info(f"Parsed trade data: {data}")

            # Prepare message for Kafka
            kafka_message = json.dumps(data).encode('utf-8')

            # Send message to MSK
            self.producer.send(os.environ['KAFKA_TOPIC'], kafka_message)
            self.producer.flush()
            logging.info(f"Successfully sent message to Kafka topic {os.environ['KAFKA_TOPIC']}.")
        except json.JSONDecodeError as e:
            logging.error(f"Error decoding JSON message: {e}")
            raise
        except Exception as e:
            logging.error(f"Error processing message: {e}")

    def on_error(self, ws, error):
        logging.error(f"WebSocket error: {error}")
        if isinstance(error, websocket.WebSocketConnectionClosedException):
            logging.info("Attempting to reconnect...")
            sleep(5)
            self.connect_to_websocket()

    def on_close(self, ws, close_status_code, close_msg):
        logging.warning(f"WebSocket closed with status code {close_status_code} and message: {close_msg}")
        # Attempt to reconnect with a delay
        sleep(5)
        self.connect_to_websocket()

    def on_open(self, ws):
        logging.info("WebSocket connection opened.")
        # Subscribe to BTC/USD trade data
        subscribe_message = {
            'type': 'subscribe',
            'symbol': 'BINANCE:BTCUSD'
        }
        ws.send(json.dumps(subscribe_message))
        logging.info("Subscription message sent.")

    def connect_to_websocket(self):
        websocket.enableTrace(True)
        self.ws = websocket.WebSocketApp(
            f"wss://ws.finnhub.io?token={os.environ['FINNHUB_API_KEY']}",
            on_message=self.on_message,
            on_error=self.on_error,
            on_close=self.on_close
        )
        self.ws.on_open = self.on_open
        logging.info("Connecting to WebSocket...")
        self.ws.run_forever()

    def graceful_shutdown(self, signum, frame):
        logging.info("Received shutdown signal. Closing connections...")
        if self.ws:
            self.ws.close()
        if self.producer:
            self.producer.close()
        logging.info("Shutdown complete.")

if __name__ == "__main__":
    connector = WebSocketKafkaConnector()

    # Setup signal handling for graceful shutdown
    signal.signal(signal.SIGINT, connector.graceful_shutdown)
    signal.signal(signal.SIGTERM, connector.graceful_shutdown)

    try:
        connector.connect_to_websocket()
    except Exception as e:
        logging.error(f"Fatal error: {e}")
        raise