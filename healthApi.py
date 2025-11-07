#!/usr/bin/env python3
"""
Simple HTTP health server for container environments
Listens on port 10000 and responds to /health endpoint
"""

import socket
import threading
import time
import os
import sys
import signal
from datetime import datetime

class HealthServer:
    def __init__(self, host='0.0.0.0', port=10000):
        self.host = host
        self.port = port
        self.server_socket = None
        self.running = False
        
    def log_message(self, message):
        """Simple logging with timestamp"""
        print(f"[{datetime.now().strftime('%H:%M:%S')}] {message}", file=sys.stderr)
    
    def handle_client(self, conn, addr):
        """Handle individual client connections"""
        try:
            # Receive request data
            data = conn.recv(1024).decode('utf-8')
            
            # Parse HTTP request
            if 'GET /health' in data:
                # Health check endpoint
                response_body = '{"status":"ok"}'
                response = (
                    'HTTP/1.1 200 OK\r\n'
                    'Content-Type: application/json\r\n'
                    f'Content-Length: {len(response_body)}\r\n'
                    '\r\n'
                    f'{response_body}'
                )
                conn.send(response.encode('utf-8'))
                self.log_message(f"Health check from {addr[0]}")
            else:
                # 404 for other endpoints
                response_body = 'Not Found'
                response = (
                    'HTTP/1.1 404 Not Found\r\n'
                    'Content-Type: text/plain\r\n'
                    f'Content-Length: {len(response_body)}\r\n'
                    '\r\n'
                    f'{response_body}'
                )
                conn.send(response.encode('utf-8'))
                self.log_message(f"404 request from {addr[0]}: {data.split()[1] if len(data.split()) > 1 else 'unknown'}")
                
        except Exception as e:
            self.log_message(f"Client handling error: {e}")
        finally:
            conn.close()
    
    def start_server(self):
        """Start the HTTP server"""
        try:
            # Create socket
            self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            self.server_socket.bind((self.host, self.port))
            self.server_socket.listen(5)
            
            self.running = True
            self.log_message(f"Health server started on {self.host}:{self.port}")
            
            while self.running:
                try:
                    # Accept new connections
                    conn, addr = self.server_socket.accept()
                    
                    # Handle each connection in a separate thread
                    client_thread = threading.Thread(target=self.handle_client, args=(conn, addr))
                    client_thread.daemon = True
                    client_thread.start()
                    
                except socket.error as e:
                    if self.running:
                        self.log_message(f"Socket error: {e}")
                        time.sleep(1)
                        
        except Exception as e:
            self.log_message(f"Failed to start health server: {e}")
            return False
        
        return True
    
    def stop_server(self):
        """Stop the HTTP server"""
        self.running = False
        if self.server_socket:
            try:
                self.server_socket.close()
            except:
                pass

def signal_handler(signum, frame):
    """Handle shutdown signals"""
    print("\nShutting down health server...")
    sys.exit(0)

def main():
    """Main function to run the health server"""
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    # Get port from environment or use default
    port = int(os.environ.get('PORT', 10000))
    host = '0.0.0.0'  # Listen on all interfaces for containers
    
    server = HealthServer(host=host, port=port)
    
    # Start the server
    if server.start_server():
        # Keep the main thread alive
        try:
            while True:
                time.sleep(60)  # Sleep for a minute at a time
        except KeyboardInterrupt:
            server.stop_server()
            sys.exit(0)
    else:
        sys.exit(1)

if __name__ == '__main__':
    main()
