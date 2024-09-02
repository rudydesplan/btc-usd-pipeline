import os
import pytest
import json
import logging
import websocket
from unittest.mock import MagicMock, patch
from btc_usd_fetcher import WebSocketKafkaConnector

# Test Kafka connection success
def test_connect_to_kafka_success(mocker):
    mocker.patch('btc_usd_fetcher.KafkaProducer')
    connector = WebSocketKafkaConnector()
    assert connector.producer is not None

# Test Kafka connection failure
def test_connect_to_kafka_failure(mocker):
    mocker.patch('btc_usd_fetcher.KafkaProducer', side_effect=Exception('Kafka error'))
    with pytest.raises(SystemExit):  # Should exit if it fails to connect
        WebSocketKafkaConnector()

# Test handling of valid WebSocket message data
def test_on_message_with_valid_data(mocker):
    mocker.patch('btc_usd_fetcher.KafkaProducer')
    connector = WebSocketKafkaConnector()
    connector.producer.send = MagicMock()

    # Mock the environment variable
    mocker.patch.dict(os.environ, {"KAFKA_TOPIC": "test_topic"})

    # Valid complex JSON message
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
    
    # Ensure that the send method was called with the correct topic and message
    connector.producer.send.assert_called_once_with(
        "test_topic",
        valid_message.encode('utf-8')
    )

# Test handling of empty WebSocket message data
def test_on_message_with_empty_data(mocker):
    mocker.patch('btc_usd_fetcher.KafkaProducer')
    connector = WebSocketKafkaConnector()
    connector.producer.send = MagicMock()

    # Empty JSON message
    empty_message = json.dumps({
        "data": [],
        "type": "trade"
    })
    
    connector.on_message(None, empty_message)
    
    # Ensure that the send method was still called, as the structure is valid
    connector.producer.send.assert_called_once_with(
        os.environ['KAFKA_TOPIC'],
        empty_message.encode('utf-8')
    )

# Test handling of invalid JSON message data
def test_on_message_with_invalid_json(mocker):
    mocker.patch('btc_usd_fetcher.KafkaProducer')
    connector = WebSocketKafkaConnector()
    connector.producer.send = MagicMock()
    
    # Invalid JSON string (not a JSON object)
    invalid_message = "This is not a JSON message"
    
    with pytest.raises(json.JSONDecodeError):
        connector.on_message(None, invalid_message)

# Test WebSocket on_open
def test_on_open(mocker):
    mock_ws = MagicMock()
    connector = WebSocketKafkaConnector()
    connector.on_open(mock_ws)
    
    # Check that the subscribe message is correctly sent
    expected_message = json.dumps({
        'type': 'subscribe',
        'symbol': 'BINANCE:BTCUSD'
    })
    mock_ws.send.assert_called_once_with(expected_message)

# Test graceful shutdown
def test_graceful_shutdown(mocker):
    mocker.patch('btc_usd_fetcher.KafkaProducer')
    connector = WebSocketKafkaConnector()
    
    # Mock the WebSocket and producer close methods
    connector.ws = MagicMock()
    connector.producer = MagicMock()
    
    with pytest.raises(SystemExit):
        connector.graceful_shutdown(None, None)
    
    connector.ws.close.assert_called_once()
    connector.producer.close.assert_called_once()

# Test WebSocket reconnection on error
def test_on_error_reconnect(mocker):
    mocker.patch('btc_usd_fetcher.KafkaProducer')
    connector = WebSocketKafkaConnector()
    
    # Mock the WebSocket methods
    connector.connect_to_websocket = MagicMock()
    error = websocket.WebSocketConnectionClosedException()
    
    connector.on_error(None, error)
    
    # Ensure it attempts to reconnect
    connector.connect_to_websocket.assert_called_once()
