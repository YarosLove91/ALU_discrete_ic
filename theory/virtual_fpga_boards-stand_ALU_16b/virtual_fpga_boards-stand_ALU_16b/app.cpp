#include <iostream>
#include <thread>
#include <vector>
#include <chrono>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <unistd.h>
#include <jsoncpp/json/json.h>
#include <signal.h>

#include "Vde2_115.h"
#include "verilated.h"

#define PORT 9090

int server_fd;
bool shutdown_flag = false;
std::vector<int> connected_clients;

void handle_signal(int signal) {
    if (signal == SIGINT) {
        std::cout << "\nShutting down server..." << std::endl;

        // Отправляем команду завершения всем клиентам
        for (int client_socket : connected_clients) {
            Json::Value shutdown_command;
            shutdown_command["command"] = "shutdown";
            Json::StreamWriterBuilder writer;
            std::string output = Json::writeString(writer, shutdown_command);
            send(client_socket, output.c_str(), output.length(), 0);
            close(client_socket);
        }

        shutdown_flag = true;
        shutdown(server_fd, SHUT_RDWR);  // Прерываем accept
        close(server_fd);  // Закрываем серверный сокет
    }
}

void handle_client(int client_socket, Vde2_115* top) {
    connected_clients.push_back(client_socket);
    char buffer[1024] = {0};
    ssize_t read_bytes = read(client_socket, buffer, 1024);

    if (read_bytes <= 0) {
        std::cerr << "Error: Failed to read data or connection closed." << std::endl;
        close(client_socket);
        return;
    }

    std::cout << "Received data: " << buffer << std::endl;

    Json::Value root;
    Json::CharReaderBuilder reader;
    std::string errs;
    std::istringstream stream(buffer);
    bool parsingSuccessful = Json::parseFromStream(reader, stream, &root, &errs);

    if (!parsingSuccessful) {
        std::cerr << "Failed to parse JSON: " << errs << std::endl;
        close(client_socket);
        return;
    }

    if (root.isMember("command") && root["command"].asString() == "shutdown") {
        std::cout << "Shutdown command received. Closing server..." << std::endl;
        close(client_socket);
        close(server_fd); 
        exit(0);          
    }

    if (!root.isMember("switches") || !root["switches"].isArray() || root["switches"].size() != 18) {
        std::cerr << "Invalid or missing 'switches' array (expected 18 switches)." << std::endl;
        close(client_socket);
        return;
    }

    Json::Value switches = root["switches"];
    uint32_t sw = 0;

    for (int i = 0; i < 18; i++) {
        if (switches[i].asBool()) {
            sw |= (1 << (17 - i));
        }
    }

    if (root.isMember("keys") && root["keys"].isArray() && root["keys"].size() >= 4) {
        Json::Value keys = root["keys"];
        top->KEY = 0; 
        for (int i = 0; i < 4; i++) {
            if (keys[i].asBool()) {
                top->KEY |= (1 << i);
            }
        }
    }

    top->SW = sw;
    top->eval();

    Json::Value response;
    response["ledr"] = Json::Value(Json::arrayValue);
    response["ledg"] = Json::Value(Json::arrayValue);
    response["displays"] = Json::Value(Json::arrayValue);

    // Красные светодиоды (LEDR)
    for (int i = 17; i >= 0; i--) {
        response["ledr"].append((top->LEDR >> i) & 1);
    }

    // Зеленые светодиоды (LEDG)
    for (int i = 7; i >= 0; i--) {
        response["ledg"].append((top->LEDG >> i) & 1);
    }

    // 7-сегментные индикаторы
    for (int i = 0; i < 8; i++) {
        uint8_t hex_value = 0xFF;  
        switch (i) {
            case 0: hex_value = top->HEX0; break;
            case 1: hex_value = top->HEX1; break;
            case 2: hex_value = top->HEX2; break;
            case 3: hex_value = top->HEX3; break;
            case 4: hex_value = top->HEX4; break;
            case 5: hex_value = top->HEX5; break;
            case 6: hex_value = top->HEX6; break;
            case 7: hex_value = top->HEX7; break;
        }
        response["displays"].append(hex_value);
    }

    Json::StreamWriterBuilder writer;
    writer["indentation"] = "";
    std::string output = Json::writeString(writer, response);
    send(client_socket, output.c_str(), output.length(), 0);
    std::cout << "Sent response: " << output << std::endl;

    connected_clients.erase(
        std::remove(connected_clients.begin(), connected_clients.end(), client_socket),
        connected_clients.end()
    );
    close(client_socket);
}

int main() {
    signal(SIGINT, handle_signal);  // Обработка SIGINT (Ctrl+C)

    const char* argv[] = {"server"};
    Verilated::commandArgs(1, argv);
    Vde2_115* top = new Vde2_115;

    struct sockaddr_in address;
    int opt = 1;
    int addrlen = sizeof(address);

    if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) == 0) {
        perror("socket failed");
        exit(EXIT_FAILURE);
    }

    if (setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR | SO_REUSEPORT, &opt, sizeof(opt))) {
        perror("setsockopt");
        exit(EXIT_FAILURE);
    }

    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(PORT);

    if (bind(server_fd, (struct sockaddr *)&address, sizeof(address)) < 0) {
        perror("bind failed");
        exit(EXIT_FAILURE);
    }

    if (listen(server_fd, 3) < 0) {
        perror("listen");
        exit(EXIT_FAILURE);
    }

    std::cout << "Server started on port " << PORT << std::endl;

    std::vector<std::thread> threads;

    while (!shutdown_flag) {
        int new_socket;
        if ((new_socket = accept(server_fd, (struct sockaddr *)&address, (socklen_t*)&addrlen)) < 0) {
            if (shutdown_flag) break;  
            perror("accept");
            continue;
        }

        threads.emplace_back(handle_client, new_socket, top);
    }

    for (auto& t : threads) {
        if (t.joinable()) {
            t.join();
        }
    }

    delete top;
    std::cout << "Server shut down." << std::endl;
    return 0;
}