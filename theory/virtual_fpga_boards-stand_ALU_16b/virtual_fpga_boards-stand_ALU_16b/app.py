import tkinter as tk
from PIL import Image, ImageTk
import pickle
import socket
import json
import argparse
import os
import configparser

HOST = '127.0.0.1'
PORT = 9090
DEFAULT_WIDTH = 600
DEFAULT_HEIGHT = 400

switches_state = [False] * 18  # 18 переключателей SW0-SW17
ledr_state = [0] * 18          # 18 красных светодиодов LEDR0-LEDR17
ledg_state = [0] * 8           # 8 зеленых светодиодов LEDG0-LEDG7
displays_state = [-1] * 8      # 8 7-сегментных индикаторов HEX0-HEX7
keys_state = [False] * 4       # 4 кнопки KEY0-KEY3

# Глобальная переменная для сокета
client_socket = None

# Позиции 7-сегментных индикаторов
hex_positions = [
    (250, 292),   # HEX0
    (230, 292),   # HEX1
    (210, 292),   # HEX2
    (190, 292),   # HEX3
    (145, 292),   # HEX4
    (125, 292),   # HEX5
    (88, 292),    # HEX6
    (68, 292)     # HEX7 
]

# Координаты сегментов для отрисовки 7-сегментного индикатора
segments = [
    [-10, -20, 10, -20],  # a (верхний сегмент)
    [10, -20, 10, 0],     # b (правый верхний)
    [10, 0, 10, 20],      # c (правый нижний)
    [-10, 20, 10, 20],    # d (нижний сегмент)
    [-10, 0, -10, 20],    # e (левый нижний)
    [-10, -20, -10, 0],   # f (левый верхний)
    [-10, 0, 10, 0],      # g (средний сегмент)
]

def cleanup():
    """Очистка ресурсов при завершении программы"""
    global client_socket
    if client_socket:
        try:
            client_socket.close()
        except:
            pass
    print("Resources cleaned up")

def on_closing():
    """Обработчик закрытия окна"""
    try:
        # Отправляем команду завершения серверу
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.settimeout(2.0)
            s.connect((HOST, PORT))
            s.sendall(json.dumps({"command": "shutdown"}).encode('utf-8'))
    except Exception as e:
        print(f"Failed to send shutdown command: {e}")
    
    cleanup()
    desktop.destroy()

def process_display_value(value):
    """Преобразует 8-битное значение в состояния сегментов индикатора"""
    if value == -1:  
        return [0] * 8  
    value = value & 0xFF
    binary_str = format(value, '08b')
    reversed_str = binary_str[::-1]
    inverted_str = ''.join(['1' if bit == '0' else '0' for bit in reversed_str])
    segments_state = [int(bit) for bit in inverted_str]
    return segments_state

def load_state():
    """Загружает сохраненное состояние всех элементов из файла"""
    try:
        with open('state.pkl', 'rb') as f:
            saved_state = pickle.load(f)
            global switches_state, keys_state
            switches_state = saved_state.get('switches', [False] * 18)
            keys_state = saved_state.get('keys', [False] * 4)
            update_gui()
            send_state()
    except FileNotFoundError:
        print("No saved state found - using defaults")
        switches_state = [False] * 18
        keys_state = [False] * 4

def save_state():
    """Сохраняет текущее состояние всех элементов в файл"""
    with open('state.pkl', 'wb') as f:
        pickle.dump({'switches': switches_state, 'keys': keys_state}, f)
    print("State saved!")

def send_state():
    """Отправляет состояние переключателей и кнопок на сервер и получает ответ"""
    global client_socket
    
    data_json = json.dumps({
        "switches": switches_state,
        "keys": keys_state
    })
    
    print(f"Sending data to server: {data_json}")

    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.settimeout(2.0)
            s.connect((HOST, PORT))
            s.sendall(data_json.encode('utf-8'))
            data_json = s.recv(1024)
            response = json.loads(data_json.decode('utf-8'))
            if response.get("command") == "shutdown":
                print("Server requested shutdown. Closing client...")
                desktop.destroy()  
                return
            
            update_indicators(response)
    except Exception as e:
        print(f"Connection error: {e}")

def reset_state():
    """Сбрасывает состояние переключателей и кнопок к значениям по умолчанию"""
    global switches_state, keys_state
    switches_state = [False] * 18
    keys_state = [False] * 4
    update_gui()
    for i in range(4):
        toggle_key(i)
    send_state()

def update_indicators(data):
    """Обновляет все индикаторы на основе данных от сервера"""
    global ledr_state, ledg_state, displays_state
    
    # Красные светодиоды (LEDR)
    for i in range(18):
        ledr_state[i] = data["ledr"][i]
    
    # Зеленые светодиоды (LEDG)
    for i in range(8):
        ledg_state[i] = data["ledg"][i]
    
    # 7-сегментные индикаторы
    displays_data = data.get("displays", [])
    for i in range(min(len(displays_data), 8)):
        displays_state[i] = displays_data[i]
    
    update_gui()

def update_gui():
    """Обновляет интерфейс пользователя"""
    # Переключатели
    for i in range(18):
        switch_image = switch_on_img if switches_state[i] else switch_off_img
        switches[i].config(image=switch_image)
        switches[i].image = switch_image
    
    # Красные светодиоды
    for i in range(18):
        led_image = ledr_on_img if ledr_state[i] else led_off_img
        ledrs[i].config(image=led_image)
        ledrs[i].image = led_image
    
    # Зеленые светодиоды
    for i in range(8):
        led_image = ledg_on_img if ledg_state[i] else led_off_img
        ledgs[i].config(image=led_image)
        ledgs[i].image = led_image
    
    # 7-сегментные индикаторы
    for i in range(8):
        draw_digit(displays[i], displays_state[i])

def toggle_switch(index):
    """Переключает состояние переключателя и отправляет состояние"""
    switches_state[index] = not switches_state[index]
    update_gui()
    send_state()

def toggle_key(key_number):
    """
    Переключает состояние кнопки и отправляет данные на сервер.
    """
    # Переключаем состояние кнопки
    keys_state[key_number] = not keys_state[key_number]
    if keys_state[key_number]:
        keys[key_number].config(relief="sunken") 
    else:
        keys[key_number].config(relief="raised")  
    send_state()  

def center_window(window, width, height):
    """Центрирует окно на экране"""
    screen_width = window.winfo_screenwidth()
    screen_height = window.winfo_screenheight()
    x = (screen_width - width) // 2
    y = (screen_height - height) // 2
    window.geometry(f"{width}x{height}+{x}+{y}")

def load_and_scale_images(x_scale, y_scale):
    """Загружает и масштабирует изображения элементов интерфейса"""
    switch_on_img = ImageTk.PhotoImage(
        Image.open("images/switch_on.jpg").resize(
            (int(14 * x_scale), int(26 * y_scale)), 
            Image.LANCZOS
        )
    )
    switch_off_img = ImageTk.PhotoImage(
        Image.open("images/switch_off.jpg").resize(
            (int(14 * x_scale), int(26 * y_scale)), 
            Image.LANCZOS   
        )
    )
    ledr_on_img = ImageTk.PhotoImage(
        Image.open("images/ledr_on.jpg").resize(
            (int(6 * x_scale), int(10 * y_scale)), 
            Image.LANCZOS
        )
    )
    ledg_on_img = ImageTk.PhotoImage(
        Image.open("images/ledg_on.jpg").resize(
            (int(6 * x_scale), int(10 * y_scale)), 
            Image.LANCZOS
        )
    )
    led_off_img = ImageTk.PhotoImage(
        Image.open("images/led_off.jpg").resize(
            (int(6 * x_scale), int(10 * y_scale)), 
            Image.LANCZOS
        )
    )   
    button_img = ImageTk.PhotoImage(
        Image.open("images/button.jpg").resize(
            (int(25 * x_scale), int(25 * y_scale)), 
            Image.LANCZOS
        )
    )
    return switch_on_img, switch_off_img, ledr_on_img, ledg_on_img, led_off_img, button_img

def draw_segment(canvas, segment, is_on, center_x, center_y, scale_x, scale_y):
    """Рисует сегмент индикатора"""
    x1, y1, x2, y2 = segment
    canvas.create_line(
        center_x + x1 * scale_x, center_y + y1 * scale_y,
        center_x + x2 * scale_x, center_y + y2 * scale_y,
        width=3 * scale_x, fill="red" if is_on else "grey"
    )

def draw_digit(canvas, value):
    """Рисует цифру на 7-сегментном индикаторе"""
    canvas.delete("all")
    if value == -1:  # Если значение не задано, не рисуем ничего
        return
        
    canvas_width = int(canvas['width'])
    canvas_height = int(canvas['height'])   
    center_x = canvas_width / 2
    center_y = canvas_height / 2
    scale_x = canvas_width / 40
    scale_y = canvas_height / 60    
    segments_state = process_display_value(value)

    # Рисуем основные 7 сегментов
    for i in range(7):
        draw_segment(canvas, segments[i], segments_state[i], center_x, center_y, scale_x, scale_y)

    # Если есть 8-й бит (десятичная точка), рисуем точку  
    if len(segments_state) > 7:
        dot_x = center_x + 15 * scale_x
        dot_y = center_y + 25 * scale_y
        radius = 3 * min(scale_x, scale_y)
        canvas.create_oval(
            dot_x - radius, dot_y - radius, dot_x + radius, dot_y + radius,
            fill="red" if (segments_state[7] == 0) else "grey", outline=""
        )

def delayed_update_positions(event=None):
    """Задержанное обновление позиций элементов"""
    if hasattr(delayed_update_positions, 'after_id'):
        desktop.after_cancel(delayed_update_positions.after_id)
    delayed_update_positions.after_id = desktop.after(100, update_positions)

def update_positions():
    """Обновляет позиции элементов при изменении размера окна"""
    new_width = desktop.winfo_width()
    new_height = desktop.winfo_height()

    if new_width < 100 or new_height < 100:
        return  

    x_scale, y_scale = new_width / DEFAULT_WIDTH, new_height / DEFAULT_HEIGHT

    global switch_on_img, switch_off_img, ledr_on_img, ledg_on_img, led_off_img, button_img 
    switch_on_img, switch_off_img, ledr_on_img, ledg_on_img, led_off_img, button_img = load_and_scale_images(x_scale, y_scale)
    
    # Обновляем фоновое изображение
    background_image_resized = background_image.resize((new_width, new_height), Image.LANCZOS)
    background_photo = ImageTk.PhotoImage(background_image_resized)
    background_label.config(image=background_photo)
    background_label.image = background_photo 

    # Обновляем переключатели
    for i in range(18):
        switches[i].config(image=switch_on_img if switches_state[i] else switch_off_img)
        switches[i].place(x=int(70 * x_scale) + i * int(17 * x_scale), y=int(350 * y_scale))

    # Обновляем красные светодиоды
    for i in range(18):
        ledrs[i].config(image=ledr_on_img if ledr_state[i] else led_off_img)
        ledrs[i].place(x=int(77 * x_scale) + i * int(17 * x_scale), y=int(335 * y_scale))

    # Обновляем зеленые светодиоды
    for i in range(8):
        ledgs[i].config(image=ledg_on_img if ledg_state[i] else led_off_img)
        ledgs[i].place(x=int(380 * x_scale) + i * int(17 * x_scale), y=int(335 * y_scale))
    
    # Обновляем 7-сегментные индикаторы
    for i in range(8):
        displays[i].config(width=max(1, int(20 * x_scale)), height=max(1, int(30 * y_scale)))
        displays[i].place(x=int(hex_positions[i][0] * x_scale), y=int(hex_positions[i][1] * y_scale))
        draw_digit(displays[i], displays_state[i])

    # Обновляем кнопки
    for i in range(4):
        keys[i].config(image=button_img)
        keys[i].place(x=int(387 * x_scale) + (3 - i) * int(34 * x_scale), y=int(350 * y_scale))
    
    save_button.config(text="Save")
    save_button.place(x=int(0 * x_scale), y=int(160 * y_scale))
    reset_button.config(text="Reset")
    reset_button.place(x=int(0 * x_scale), y=int(240 * y_scale))
    load_button.config(text="Load")
    load_button.place(x=int(0 * x_scale), y=int(200 * y_scale))

def load_config(config_file='config.ini'):
    """Загружает конфигурацию из файла"""
    config = configparser.ConfigParser()
    # Значения по умолчанию
    default_config = {
        'width': '800',
        'height': '500',
    }
    
    if os.path.exists(config_file):
        try:
            config.read(config_file)
            # Проверяем, что значения в файле корректные
            if not config['DEFAULT'].getint('width', fallback=0) > 100:
                raise ValueError("Некорректная ширина в конфиге")
            if not config['DEFAULT'].getint('height', fallback=0) > 100:
                raise ValueError("Некорректная высота в конфиге")
        except Exception as e:
            config['DEFAULT'] = default_config
    else:
        config['DEFAULT'] = default_config
        # Создаем файл с настройками по умолчанию
        with open(config_file, 'w') as f:
            config.write(f)
    
    return config

# Настройка аргументов командной строки
parser = argparse.ArgumentParser(description="Эмулятор DE2-115")
parser.add_argument("--width", type=int, help="Ширина окна")
parser.add_argument("--height", type=int, help="Высота окна")
parser.add_argument("--config", default='config.ini', help="Путь к файлу конфигурации")
args = parser.parse_args()

# Загружаем конфигурацию
config = configparser.ConfigParser()
config.read(args.config if os.path.exists(args.config) else 'config.ini')

# Определяем размеры окна
user_width = args.width if args.width else config.getint('DEFAULT', 'width', fallback=800)
user_height = args.height if args.height else config.getint('DEFAULT', 'height', fallback=500)

# Создаем главное окно
desktop = tk.Tk()
desktop.title("Эмулятор DE2-115")

desktop.protocol("WM_DELETE_WINDOW", on_closing)

# Центрируем окно
center_window(desktop, user_width, user_height)

# Загружаем фоновое изображение
background_image = Image.open('images/de2-115.png')
background_photo = ImageTk.PhotoImage(background_image.resize((user_width, user_height), Image.LANCZOS))
background_label = tk.Label(desktop, image=background_photo)
background_label.place(x=0, y=0, relwidth=1, relheight=1)

# Масштабируем изображения
x_scale, y_scale = user_width / DEFAULT_WIDTH, user_height / DEFAULT_HEIGHT
switch_on_img, switch_off_img, ledr_on_img, ledg_on_img, led_off_img, button_img = load_and_scale_images(x_scale, y_scale)

# Создаем элементы интерфейса
switches = []
ledrs = []
ledgs = []
displays = []
keys = []

# Переключатели (SW0-SW17)
for i in range(18):
    switch = tk.Label(desktop, image=switch_on_img if switches_state[i] else switch_off_img)
    switch.bind("<Button-1>", lambda event, i=i: toggle_switch(i))
    switches.append(switch)

# Красные светодиоды (LEDR0-LEDR17)
for i in range(18):
    led = tk.Label(desktop, image=ledr_on_img if ledr_state[i] else led_off_img)
    ledrs.append(led)

# Зеленые светодиоды (LEDG0-LEDG7)
for i in range(8):
    led = tk.Label(desktop, image=ledg_on_img if ledg_state[i] else led_off_img)
    ledgs.append(led)

# 7-сегментные индикаторы (HEX0-HEX7)
for i in range(8):
    display = tk.Canvas(desktop, width=20 * x_scale, height=30 * y_scale, bg='black')
    displays.append(display)
    draw_digit(display, displays_state[i])

# Кнопки (KEY0-KEY3)
for i in range(4):
    key = tk.Button(desktop, text=f"KEY{i}", command=lambda i=i: toggle_key(i))
    keys.append(key)

save_button = tk.Button(desktop, text="Save", command=save_state)
save_button.place(x=int(0 * x_scale), y=int(200 * y_scale))

load_button = tk.Button(desktop, text="Load", command=load_state)
load_button.place(x=int(0 * x_scale), y=int(160 * y_scale))

reset_button = tk.Button(desktop, text="Reset", command=lambda: [reset_state(), send_state()])
reset_button.place(x=int(0 * x_scale), y=int(240 * y_scale))

update_positions()

desktop.bind("<Configure>", delayed_update_positions)

desktop.mainloop()