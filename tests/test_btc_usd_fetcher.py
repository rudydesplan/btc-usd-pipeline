import os
import pytest
import json
import logging
import websocket
from unittest.mock import MagicMock, patch
from src.fetcher.btc_usd_fetcher import WebSocketKafkaConnector

@pytest.fixture
def mock_kafka(mocker):
    mocker.patch('src.fetcher.btc_usd_fetcher.KafkaProducer')
    mocker.patch.object(WebSocketKafkaConnector, 'connect_to_kafka')

# Test Kafka connection success
def test_connect_to_kafka_success(mock_kafka):
    connector = WebSocketKafkaConnector()
    assert connector.producer is not None

# Test Kafka connection failure
def test_connect_to_kafka_failure(mocker, mock_kafka):
    mocker.patch('src.fetcher.btc_usd_fetcher.KafkaProducer', side_effect=Exception('Kafka error'))
    with pytest.raises(ConnectionError):
        WebSocketKafkaConnector()

# Test handling of valid WebSocket message data
def test_on_message_with_valid_data(mock_kafka):
    connector = WebSocketKafkaConnector()
    connector.producer.send = MagicMock()
    
    valid_message = json.dumps({
        "data": [
            {
                "p": 7296.89,
                "s": "BINANCE:BTCUSD",
                "t": 1575526691134,
                "v": 0.011467
            }
        ],
        "type": "trade"
    })
    
    connector.on_message(None, valid_message)
    
    connector.producer.send.assert_called_once_with(
        os.environ.get('KAFKA_TOPIC', 'default_topic'),
        valid_message.encode('utf-8')
    )

# Test handling of empty WebSocket message data
def test_on_message_with_empty_data(mock_kafka):
    connector = WebSocketKafkaConnector()
    connector.producer.send = MagicMock()
    
    empty_message = json.dumps({
        "data": [],
        "type": "trade"
    })
    
    connector.on_message(None, empty_message)
    
    connector.producer.send.assert_called_once_with(
        os.environ.get('KAFKA_TOPIC', 'default_topic'),
        empty_message.encode('utf-8')
    )

# Test handling of invalid JSON message data
def test_on_message_with_invalid_json(mock_kafka):
    connector = WebSocketKafkaConnector()
    
    invalid_message = "This is not a JSON message"
    
    with pytest.raises(json.JSONDecodeError):
        connector.on_message(None, invalid_message)

# Test WebSocket on_open
def test_on_open(mock_kafka):
    mock_ws = MagicMock()
    connector = WebSocketKafkaConnector()
    connector.on_open(mock_ws)
    
    expected_message = json.dumps({
        'type': 'subscribe',
        'symbol': 'BINANCE:BTCUSD'
    })
    mock_ws.send.assert_called_once_with(expected_message)

# Test graceful shutdown
def test_graceful_shutdown(mock_kafka):
    connector = WebSocketKafkaConnector()
    
    connector.ws = MagicMock()
    connector.producer = MagicMock()
    
    connector.graceful_shutdown(None, None)
    
    connector.ws.close.assert_called_once()
    connector.producer.close.assert_called_once()

# Test WebSocket reconnection on error
def test_on_error_reconnect(mock_kafka):
    connector = WebSocketKafkaConnector()
    
    connector.connect_to_websocket = MagicMock()
    error = websocket.WebSocketConnectionClosedException()
    
    connector.on_error(None, error)
    
    connector.connect_to_websocket.assert_called_once()