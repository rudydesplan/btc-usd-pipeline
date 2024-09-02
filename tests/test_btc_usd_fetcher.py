import os
import pytest
import json
import logging
import websocket
from unittest.mock import MagicMock, patch
from src.fetcher.btc_usd_fetcher import WebSocketKafkaConnector

# Test Kafka connection success
def test_connect_to_kafka_success(mocker):
    mocker.patch('src.fetcher.btc_usd_fetcher.KafkaProducer')
    connector = WebSocketKafkaConnector()
    assert connector.producer is not None

# Test Kafka connection failure
def test_connect_to_kafka_failure(mocker):
    mocker.patch('src.fetcher.btc_usd_fetcher.KafkaProducer', side_effect=Exception('Kafka error'))
    with pytest.raises(Exception):  # Assuming you've updated the class to raise an exception instead of sys.exit
        WebSocketKafkaConnector()

# Test handling of valid WebSocket message data
def test_on_message_with_valid_data(mocker):
    mock_producer = mocker.patch('src.fetcher.btc_usd_fetcher.KafkaProducer').return_value
    connector = WebSocketKafkaConnector()
    
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
    
    mock_producer.send.assert_called_once_with(
        os.environ.get('KAFKA_TOPIC', 'default_topic'),
        valid_message.encode('utf-8')
    )

# Test handling of empty WebSocket message data
def test_on_message_with_empty_data(mocker):
    mock_producer = mocker.patch('src.fetcher.btc_usd_fetcher.KafkaProducer').return_value
    connector = WebSocketKafkaConnector()
    
    empty_message = json.dumps({
        "data": [],
        "type": "trade"
    })
    
    connector.on_message(None, empty_message)
    
    mock_producer.send.assert_called_once_with(
        os.environ.get('KAFKA_TOPIC', 'default_topic'),
        empty_message.encode('utf-8')
    )

# Test handling of invalid JSON message data
def test_on_message_with_invalid_json(mocker):
    mocker.patch('src.fetcher.btc_usd_fetcher.KafkaProducer')
    connector = WebSocketKafkaConnector()
    
    invalid_message = "This is not a JSON message"
    
    with pytest.raises(json.JSONDecodeError):
        connector.on_message(None, invalid_message)

# Test WebSocket on_open
def test_on_open(mocker):
    mock_ws = MagicMock()
    connector = WebSocketKafkaConnector()
    connector.on_open(mock_ws)
    
    expected_message = json.dumps({
        'type': 'subscribe',
        'symbol': 'BINANCE:BTCUSD'
    })
    mock_ws.send.assert_called_once_with(expected_message)

# Test graceful shutdown
def test_graceful_shutdown(mocker):
    mocker.patch('src.fetcher.btc_usd_fetcher.KafkaProducer')
    connector = WebSocketKafkaConnector()
    
    connector.ws = MagicMock()
    connector.producer = MagicMock()
    
    connector.graceful_shutdown(None, None)
    
    connector.ws.close.assert_called_once()
    connector.producer.close.assert_called_once()

# Test WebSocket reconnection on error
def test_on_error_reconnect(mocker):
    mocker.patch('src.fetcher.btc_usd_fetcher.KafkaProducer')
    connector = WebSocketKafkaConnector()
    
    connector.connect_to_websocket = MagicMock()
    error = websocket.WebSocketConnectionClosedException()
    
    connector.on_error(None, error)
    
    connector.connect_to_websocket.assert_called_once()