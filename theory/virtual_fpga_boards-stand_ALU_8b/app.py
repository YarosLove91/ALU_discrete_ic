import tkinter as tk
from PIL import Image, ImageTk
import pickle
import socket
import json
import argparse
import os
import configparser

HOST = '127.0.0.1'
PORT = 8080
DEFAULT_WIDTH = 600
DEFAULT_HEIGHT = 400

switches_state = [False] * 10
leds_state = [0] * 10
displays_state = [-1] * 6
keys_state = [False] * 2

# Глобальная переменная для сокета
client_socket = None

# Координаты сегментов для отрисовки 7-сегментного индикатора
# Каждый сегмент задается координатами [x1, y1, x2, y2]
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
    """Функция для очистки ресурсов при завершении программы"""
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
    
    cleanup()  # Закрываем клиентский сокет
    desktop.destroy()  # Закрываем окно

def process_display_value(value):
    """
    Преобразует 8-битное значение в состояния сегментов индикатора
    Args:
        value (int): Числовое значение для отображения (0-255)
    Returns:
        list: Состояния 7 сегментов (1 - включен, 0 - выключен)
    """
    if value == -1:  
        return [0] * 8  
    
    value = value & 0xFF
    if value == 0:
        return [0] * 8  
    
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
            
            global switches_state
            switches_state = saved_state.get('switches', [False] * 10)
            
            global keys_state
            keys_state = saved_state.get('keys', [False] * 2)
            
            for i in range(10):
                update_switch_image(i)

            send_state()
            
    except FileNotFoundError:
        print("No saved state found - using defaults")
        switches_state = [False] * 10
        keys_state = [False] * 2

def save_state():
    """Сохраняет текущее состояние переключателей в файл"""
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
    switches_state = [False] * 10
    keys_state = [True] * 2
    for i in range(10):
        update_switch_image(i)
    for i in range(2):
        toggle_key(i)
    send_state()

def update_indicators(data):
    """
    Обновляет состояние светодиодов и индикаторов на основе данных от сервера
    Args:
        data (dict): Словарь с ключами "leds" и "displays"
    """
    leds_data = data.get("leds", [])
    for i in range(min(len(leds_data), 10)):
        leds_state[i] = leds_data[i]
    for i in range(10):  
        led_image = led_on_img if leds_state[i] == 1 else led_off_img
        labels[i].config(image=led_image)
        labels[i].image = led_image  

    displays_data = data.get("displays", [])
    for i in range(min(len(displays_data), 6)):
        displays_state[i] = displays_data[i]  
    for i in range(min(len(displays_data), 6)):  
        val = displays_data[i] if i < len(displays_data) else -1
        draw_digit(displays[i], val) 

def toggle_switch(switch_number):
    """Переключает состояние указанного переключателя и обновляет его изображение"""
    switches_state[switch_number] = not switches_state[switch_number]
    update_switch_image(switch_number)
    send_state() 

def update_switch_image(switch_number):
    """Обновляет изображение переключателя в соответствии с его текущим состоянием"""
    switch_image = switch_on_img if switches_state[switch_number] else switch_off_img
    switches[switch_number].config(image=switch_image)
    switches[switch_number].image = switch_image  

def toggle_key(key_number):
    """
    Активирует кнопку только на момент нажатия.
    """
    keys_state[key_number] = True
    keys[key_number].config(relief="sunken")  # Визуально кнопка "зажата"
    send_state()  # Отправляем состояние на сервер

    # Возвращаем кнопку в исходное состояние через короткое время
    desktop.after(100, lambda: release_key(key_number))

def release_key(key_number):
    """
    Возвращает кнопку в исходное состояние.
    """
    keys_state[key_number] = False
    keys[key_number].config(relief="raised")  # Визуально кнопка "отпущена"
    send_state()  # Отправляем состояние на сервер 

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
            (int(20 * x_scale), int(40 * y_scale)), 
            Image.LANCZOS
        )
    )
    switch_off_img = ImageTk.PhotoImage(
        Image.open("images/switch_off.jpg").resize(
            (int(20 * x_scale), int(40 * y_scale)), 
            Image.LANCZOS
        )
    )
    led_on_img = ImageTk.PhotoImage(
        Image.open("images/led_on.jpg").resize(
            (int(20 * x_scale), int(10 * y_scale)), 
            Image.LANCZOS
        )
    )
    led_off_img = ImageTk.PhotoImage(
        Image.open("images/led_off.jpg").resize(
            (int(20 * x_scale), int(10 * y_scale)), 
            Image.LANCZOS
        )
    )
    button_img = ImageTk.PhotoImage(
        Image.open("images/button.jpg").resize(
            (int(20 * x_scale), int(20 * y_scale)), 
            Image.LANCZOS
        )
    )
    return switch_on_img, switch_off_img, led_on_img, led_off_img, button_img

def update_elements(x_scale, y_scale, switch_on_img, switch_off_img, led_on_img, led_off_img, button_img):
    """Обновляет все элементы интерфейса при изменении размера окна"""
    # Масштабируем фоновое изображение
    background_image_resized = background_image.resize((desktop.winfo_width(), desktop.winfo_height()), Image.LANCZOS)
    background_photo = ImageTk.PhotoImage(background_image_resized)
    background_label.config(image=background_photo)
    background_label.image = background_photo 

    # Обновляем переключатели
    for i in range(10):
        switch_image = switch_on_img if switches_state[i] else switch_off_img
        switches[i].config(image=switch_image)
        switches[i].image = switch_image  
        switches[i].place(x=int(302 * x_scale) + i * int(24 * x_scale), y=int(333 * y_scale))

    # Обновляем светодиоды
    for i in range(10):
        led_image = led_on_img if leds_state[i] else led_off_img
        labels[i].config(image=led_image)
        labels[i].image = led_image  
        labels[i].place(x=int(304 * x_scale) + i * int(24 * x_scale), y=int(316 * y_scale))

    # Обновляем 7-сегментные дисплеи
    for i in range(6):
        displays[i].config(width=max(1, int(40 * x_scale)), height=max(1, int(60 * y_scale)))
        displays[i].place(x=int(255 * x_scale) - i * int(39 * x_scale), y=int(320 * y_scale))
        draw_digit(displays[i], displays_state[i])  
    for i in range(2):
        keys[i].config(image=button_img)
        keys[i].image = button_img  
        keys[i].place(x=int(508 * x_scale), y=int(240 * y_scale) + i * int(36 * y_scale))
    
    save_button.config(text="Save")
    save_button.place(x=int(0 * x_scale), y=int(160 * y_scale))
    reset_button.config(text="Reset")
    reset_button.place(x=int(0 * x_scale), y=int(240 * y_scale))
    load_button.config(text="Load")
    load_button.place(x=int(0 * x_scale), y=int(200 * y_scale))


def update_positions(event=None):
    """Обработчик изменения размера окна"""
    new_width = desktop.winfo_width()
    new_height = desktop.winfo_height()

    # Игнорируем слишком маленькие размеры
    if new_width < 100 or new_height < 100:
        return  

    x_scale, y_scale = get_scaling_factors(new_width, new_height)

    global switch_on_img, switch_off_img, led_on_img, led_off_img, button_img 
    switch_on_img, switch_off_img, led_on_img, led_off_img, button_img = load_and_scale_images(x_scale, y_scale)
    update_elements(x_scale, y_scale, switch_on_img, switch_off_img, led_on_img, led_off_img, button_img)

def get_scaling_factors(user_width, user_height):
    """Вычисляет коэффициенты масштабирования относительно стандартных размеров"""
    x = user_width / DEFAULT_WIDTH
    y = user_height / DEFAULT_HEIGHT
    return x, y

def draw_segment(canvas, segment, is_on, center_x, center_y, scale_x, scale_y):
    x1, y1, x2, y2 = segment
    canvas.create_line(
        center_x + x1 * scale_x, center_y + y1 * scale_y,
        center_x + x2 * scale_x, center_y + y2 * scale_y,
        width=3 * scale_x, fill="red" if is_on else "grey"
    )

def draw_digit(canvas, value):
    """Рисует цифру на 7-сегментном индикаторе"""
    canvas.delete("all")
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
            fill="red" if (segments_state[7] == 1) else "grey", outline=""
        )

def delayed_update_positions(event=None):
    """Задержанное обновление позиций элементов (для обработки изменения размера окна)"""
    if hasattr(delayed_update_positions, 'after_id'):
        desktop.after_cancel(delayed_update_positions.after_id)
    delayed_update_positions.after_id = desktop.after(100, update_positions)

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
parser = argparse.ArgumentParser(description="Эмулятор DE10 Lite")
parser.add_argument("--width", type=int, help="Ширина окна (переопределяет конфиг)")
parser.add_argument("--height", type=int, help="Высота окна (переопределяет конфиг)")
parser.add_argument("--config", default='config.ini', help="Путь к файлу конфигурации")
args = parser.parse_args()

# Загружаем конфигурацию из файла
config = load_config(args.config)

# Определение размеров окна с приоритетом:
# 1. Аргументы командной строки
# 2. Конфигурационный файл
user_width = args.width if args.width else config['DEFAULT'].getint('width')
user_height = args.height if args.height else config['DEFAULT'].getint('height')

print(f"Launched with: {user_width}x{user_height}")
print(f"Config: {args.config}")

desktop = tk.Tk()
desktop.title("Эмулятор DE10 Lite")

desktop.protocol("WM_DELETE_WINDOW", on_closing)

center_window(desktop, user_width, user_height)

background_image = Image.open('images/de10-lite.jpg')
background_photo = ImageTk.PhotoImage(background_image.resize((user_width, user_height), Image.LANCZOS))
background_label = tk.Label(desktop, image=background_photo)
background_label.place(x=0, y=0, relwidth=1, relheight=1)

x_scale, y_scale = get_scaling_factors(user_width, user_height)
switch_on_img, switch_off_img, led_on_img, led_off_img, button_img = load_and_scale_images(x_scale, y_scale)

switches = []
labels = []

for i in range(10):
    switch_image = switch_on_img if switches_state[i] else switch_off_img
    button = tk.Label(desktop, image=switch_image)
    button.place(x=int(302 * x_scale) + i * int(24 * x_scale), y=int(333 * y_scale))
    button.bind("<Button-1>", lambda event, i=i: toggle_switch(i))
    switches.append(button)

    led_image = led_off_img
    label = tk.Label(desktop, image=led_image)
    label.place(x=int(304 * x_scale) + i * int(24 * x_scale), y=int(316 * y_scale))
    labels.append(label)

displays = []
for i in range(6):
    display_canvas = tk.Canvas(desktop, width=40 * x_scale, height=60 * y_scale, bg='black')
    display_canvas.place(x=int(255 * x_scale) - i * int(39 * x_scale), y=int(320 * y_scale))
    displays.append(display_canvas)
    draw_digit(display_canvas, -1)

keys = []
for i in range(2):
    key = tk.Button(desktop, command=lambda i=i: toggle_key(i))
    key.place(x=int(508 * x_scale), y=int(240 * y_scale) + i * int(36 * y_scale))
    keys.append(key)

save_button = tk.Button(desktop, text="Save", command=save_state)
save_button.place(x=int(0 * x_scale), y=int(200 * y_scale))

load_button = tk.Button(desktop, text="Load", command=load_state)
load_button.place(x=int(0 * x_scale), y=int(160 * y_scale))

reset_button = tk.Button(desktop, text="Reset", command=lambda: [reset_state(), send_state()])
reset_button.place(x=int(0 * x_scale), y=int(240 * y_scale))

desktop.bind("<Configure>", delayed_update_positions)

desktop.mainloop()
