#!/usr/bin/python

import serial
import tkinter as tk
from tkinter import ttk
from tkinter import colorchooser

# LED PWM IP
LEDDPWRR = 0x01
LEDDPWRG = 0x02
LEDDPWRB = 0x03
LEDDBCRR = 0x05
LEDDBCFR = 0x06
LEDDCR0 = 0x08
LEDDBR = 0x09
LEDDONR = 0x0A
LEDDOFR = 0x0B
LEDDEXE = 0xFF

# Windows
top = tk.Tk()
top.title('iCESugar LED PWM IP Demo')
top.resizable(width=False, height=False)

def send_cmd(addr, data):
    global ser

    ser.write(bytearray([addr, data]))

# UART
uart = tk.LabelFrame(top, text='UART Configuration')
uart.grid(row=0, column=0, sticky='nsew')

def on_uart():
    global uart_btn

    if uart_btn['text'] == 'Connect':
        uart_connect()
        uart_btn['text'] = 'Disconnect'
    else:
        uart_btn['text'] = 'Connect'

def uart_connect():
    global dev_name_value
    global led_on
    global led_off
    global rgb_btn
    global ser

    ser = serial.Serial(dev_name_value.get(), 115200)

    send_led_basic()
    send_cmd(LEDDONR, led_on.current())
    send_cmd(LEDDOFR, led_off.current())
    send_breathe_on()
    send_breathe_off()
    send_color(rgb_btn['bg'])
    send_led_ctrl()

def uart_disconnect():
    global ser

    ser.flush()
    if ser.isOpen():
        ser.close()

tk.Label(uart, text='Device').grid(row=0, column=0)
dev_name_value = tk.StringVar(uart)
dev_name_value.set('COM1')
dev_name = tk.Entry(uart, textvariable=dev_name_value)
dev_name.grid(row=0, column=1)

uart_btn = tk.Button(uart, text='Connect', width=10, command=on_uart)
uart_btn.grid(row=0, column=2)

# LEDDEXE
def send_led_ctrl():
    global led_ctrl_btn

    if led_ctrl_btn['text'] == 'LED OFF':
        send_cmd(LEDDEXE, 1)
    else:
        send_cmd(LEDDEXE, 0)

def on_led_ctrl():
    global led_ctrl_btn

    if led_ctrl_btn['text'] == 'LED ON':
        led_ctrl_btn['text'] = 'LED OFF'
    else:
        led_ctrl_btn['text'] = 'LED ON'
    
    send_led_ctrl()

led_ctrl_btn = tk.Button(top, text='LED ON', width=10, height=2, command=on_led_ctrl)
led_ctrl_btn.grid(row=0, column=1)

# LEDDCR0 & LEDDBR
def send_led_basic():
    global led_driver
    global clk_prescale
    global flick_rate
    global pwm_pol
    global pwm_skew
    global quick_stop
    global pwm_mode

    prescale = int(clk_prescale.get())

    data = (led_driver.get()     << 7) | \
           (flick_rate.current() << 6) | \
           (pwm_pol.current()    << 5) | \
           (pwm_skew.get()       << 4) | \
           (quick_stop.get()     << 3) | \
           (pwm_mode.current()   << 2) | \
           ((prescale - 1)       >> 8)

    send_cmd(LEDDCR0, data)
    send_cmd(LEDDBR, (prescale - 1) & 0xFF)

basic = tk.LabelFrame(top, text='Basic Configuration')
basic.grid(row=1, column=0, sticky='nsew')

# LEDDEN
tk.Label(basic, text='LED Driver').grid(row=0, column=0, sticky='w')
led_driver = tk.IntVar()
led_driver.set(1)
tk.Checkbutton(basic, variable=led_driver, command=send_led_basic, onvalue=1, offvalue=0).grid(row=0, column=1, sticky='w')

# BR
def update_prescale():
    global clk_prescale

    prescale = int(clk_prescale.get())

    update_led_clk(prescale)
    update_flick_rate(prescale)
    update_led_drive_on(prescale)
    update_led_drive_off(prescale)
    update_breathe_on_rate(prescale)
    update_breathe_off_rate(prescale)

def on_clk_prescale():
    update_prescale()

    send_led_basic()

def update_led_clk(prescale):
    led_clk['text'] = '%.1f kHz' % (12000 / prescale)

tk.Label(basic, text='Clock Pre-scale (1 - 1024)').grid(row=1, column=0, sticky='w')

clk_prescale_value = tk.StringVar(basic)
clk_prescale_value.set('183')
clk_prescale = tk.Spinbox(basic, from_=1, to=1024, textvariable=clk_prescale_value, width=4, state='readonly', command=on_clk_prescale)
clk_prescale.grid(row=1, column=1, sticky='w')

led_clk = tk.Label(basic)
led_clk.grid(row=1, column=1, sticky='e')

# FR250
def update_flick_rate(prescale):
    global flick_rate

    double_rate = 12000000 / prescale / 256
    cur = flick_rate.current()
    flick_rate['values'] = ['%.0f Hz' % (double_rate / 2), '%.0f Hz' % double_rate]
    flick_rate.current(cur)

tk.Label(basic, text='Flick Rate').grid(row=2, column=0, sticky='w')
flick_rate = ttk.Combobox(basic, state='readonly', width=6)
flick_rate.grid(row=2, column=1, sticky='w')
flick_rate.bind('<<ComboboxSelected>>', lambda e: send_led_basic())
flick_rate['values'] = ['' for i in range(2)]
flick_rate.current(1)

# OUTPOL
tk.Label(basic, text='PWM Outputs Polarity').grid(row=3, column=0, sticky='w')
pwm_pol = ttk.Combobox(basic, state='readonly', width=11)
pwm_pol.grid(row=3, column=1, sticky='w')
pwm_pol.bind('<<ComboboxSelected>>', lambda e: send_led_basic())
pwm_pol['values'] = ['Active High', 'Active Low']
pwm_pol.current(0)

# OUTSKEW
tk.Label(basic, text='PWM Output Skew').grid(row=4, column=0, sticky='w')
pwm_skew = tk.IntVar()
tk.Checkbutton(basic, variable=pwm_skew, command=send_led_basic, onvalue=1, offvalue=0).grid(row=4, column=1, sticky='w')

# QUICK_STOP
tk.Label(basic, text='Blinking Sequence Quick Stop').grid(row=5, column=0, sticky='w')
quick_stop = tk.IntVar()
tk.Checkbutton(basic, variable=quick_stop, command=send_led_basic, onvalue=1, offvalue=0).grid(row=5, column=1, sticky='w')

# PWM_MODE
tk.Label(basic, text='PWM Mode').grid(row=6, column=0, sticky='w')
pwm_mode = ttk.Combobox(basic, state='readonly', width=6)
pwm_mode.grid(row=6, column=1, sticky='w')
pwm_mode.bind('<<ComboboxSelected>>', lambda e: send_led_basic())
pwm_mode['values'] = ['Linear', 'LFSR']
pwm_mode.current(0)

# LEDDPWRR, LEDDPWRG & LEDDPWRB
color = tk.LabelFrame(top, text='LED Color')
color.grid(row=2, column=0, sticky='nsew')

# Color
def get_color():
    global rgb_btn
    global rgb_label

    rgb = colorchooser.askcolor(color=rgb_btn['bg'])[1]
    rgb_btn['bg'] = rgb
    rgb_label['text'] = rgb

    send_color(rgb)

def send_color(rgb):
    send_cmd(LEDDPWRR, int(rgb[1:3], 16))
    send_cmd(LEDDPWRG, int(rgb[3:5], 16))
    send_cmd(LEDDPWRB, int(rgb[5:7], 16))

tk.Label(color, text='RGB Color').grid(row=0, column=0, sticky='w')
rgb_btn = tk.Button(color, bg='#FFFFFF', width=5, command=get_color)
rgb_btn.grid(row=0, column=1)
rgb_label = tk.Label(color, text='#FFFFFF')
rgb_label.grid(row=0, column=2)

# LEDDONR, LEDDOFR, LEDDBCRR & LEDDBCFR
def send_breathe_on():
    global breathe_on_enable
    global breathe_edge
    global breathe_on_mode
    global breathe_on_rate

    data = (breathe_on_enable.get()   << 7) | \
           (breathe_edge.get()        << 6) | \
           (breathe_on_mode.current() << 5) | \
           (breathe_on_rate.current() << 0)
    
    send_cmd(LEDDBCRR, data)

def send_breathe_off():
    global breathe_off_enable
    global pwm_range
    global breathe_on_mode
    global breathe_on_rate

    data = (breathe_off_enable.get()   << 7) | \
           (pwm_range.get()            << 6) | \
           (breathe_off_mode.current() << 5) | \
           (breathe_off_rate.current() << 0)
    
    send_cmd(LEDDBCFR, data)

timing = tk.LabelFrame(top, text='LED Timing')
timing.grid(row=1, column=1, rowspan=2, sticky='nsew')

# LEDDONR
def update_led_drive_on(prescale):
    global led_on

    cur = led_on.current()
    led_on['values'] = ['%.3f s' % (i / (12000000 / prescale / 256 / 8)) for i in range(256)]
    led_on.current(cur)

tk.Label(timing, text='LED Blink ON Time').grid(row=0, column=0, sticky='w')
led_on = ttk.Combobox(timing, state='readonly', width=7)
led_on.grid(row=0, column=1, sticky='w')
led_on.bind('<<ComboboxSelected>>', lambda e: send_cmd(LEDDONR, led_on.current()))
led_on['values'] = ['' for i in range(256)]
led_on.current(32)

# LEDDOFR
def update_led_drive_off(prescale):
    global led_off

    cur = led_off.current()
    led_off['values'] = ['%.3f s' % (i / (12000000 / prescale / 256 / 8)) for i in range(256)]
    led_off.current(cur)

tk.Label(timing, text='LED Blink OFF Time').grid(row=1, column=0, sticky='w')
led_off = ttk.Combobox(timing, state='readonly', width=7)
led_off.grid(row=1, column=1, sticky='w')
led_off.bind('<<ComboboxSelected>>', lambda e: send_cmd(LEDDOFR, led_off.current()))
led_off['values'] = ['' for i in range(256)]
led_off.current(32)

# BREATHE_ON_ENABLE
def on_breathe_on_enable():
    global breathe_on_enable
    global breathe_on_mode
    global breathe_on_rate

    send_breathe_on()

    if breathe_on_enable.get() == 0:
        breathe_on_mode['state'] = 'disabled'
        breathe_on_rate['state'] = 'disabled'
    else:
        breathe_on_mode['state'] = 'readonly'
        breathe_on_rate['state'] = 'readonly'

tk.Label(timing, text='Breathe ON Enable').grid(row=2, column=0, sticky='w')
breathe_on_enable = tk.IntVar()
breathe_on_enable.set(1)
tk.Checkbutton(timing, variable=breathe_on_enable, onvalue=1, offvalue=0, command=on_breathe_on_enable).grid(row=2, column=1, sticky='w')

# BREATHE_ON_MODE
tk.Label(timing, text='Breathe ON Mode').grid(row=3, column=0, sticky='w')
breathe_on_mode = ttk.Combobox(timing, state='readonly', width=8)
breathe_on_mode.grid(row=3, column=1, sticky='w')
breathe_on_mode.bind('<<ComboboxSelected>>', lambda e: send_breathe_on())
breathe_on_mode['values'] = ['Unique', 'Modulate']
breathe_on_mode.current(1)

# BREATH_ON_RATE
def update_breathe_on_rate(prescale):
    global breathe_on_rate

    cur = breathe_on_rate.current()
    breathe_on_rate['values'] = ['%.3f s' % ((i + 1) / (12000000 / prescale / 256 / 32)) for i in range(16)]
    breathe_on_rate.current(cur)

tk.Label(timing, text='Breathe ON Rate').grid(row=4, column=0, sticky='w')
breathe_on_rate = ttk.Combobox(timing, state='readonly', width=7)
breathe_on_rate.grid(row=4, column=1, sticky='w')
breathe_on_rate.bind('<<ComboboxSelected>>', lambda e: send_breathe_on())
breathe_on_rate['values'] = ['' for i in range(16)]
breathe_on_rate.current(7)

# BREATHE_EDGE
def on_breathe_edge():
    global breathe_off_enable
    global breathe_off_mode
    global breathe_off_rate

    send_breathe_on()

    if breathe_edge.get() == 1:
        breathe_off_enable_btn['state'] = 'disabled'
        breathe_off_mode['state'] = 'disabled'
        breathe_off_rate['state'] = 'disabled'
    else:
        breathe_off_enable_btn['state'] = 'normal'
        if breathe_off_enable.get() == 0:
            breathe_off_mode['state'] = 'disabled'
            breathe_off_rate['state'] = 'disabled'
        else:
            breathe_off_mode['state'] = 'readonly'
            breathe_off_rate['state'] = 'readonly'

tk.Label(timing, text='Apply both ON/OFF Ramp').grid(row=5, column=0, sticky='w')
breathe_edge = tk.IntVar()
breathe_edge.set(0)
tk.Checkbutton(timing, variable=breathe_edge, onvalue=1, offvalue=0, command=on_breathe_edge).grid(row=5, column=1, sticky='w')

# BREATHE_OFF_ENABLE
def on_breathe_off_enable():
    global breathe_off_enable
    global breathe_off_mode
    global breathe_off_rate

    send_breathe_off()

    if breathe_off_enable.get() == 0:
        breathe_off_mode['state'] = 'disabled'
        breathe_off_rate['state'] = 'disabled'
    else:
        breathe_off_mode['state'] = 'readonly'
        breathe_off_rate['state'] = 'readonly'

tk.Label(timing, text='Breathe OFF Enable').grid(row=6, column=0, sticky='w')
breathe_off_enable = tk.IntVar()
breathe_off_enable.set(1)
breathe_off_enable_btn = tk.Checkbutton(timing, variable=breathe_off_enable, onvalue=1, offvalue=0, command=on_breathe_off_enable)
breathe_off_enable_btn.grid(row=6, column=1, sticky='w')

# BREATHE_OFF_MODE
tk.Label(timing, text='Breathe OFF Mode').grid(row=7, column=0, sticky='w')
breathe_off_mode = ttk.Combobox(timing, state='readonly', width=8)
breathe_off_mode.grid(row=7, column=1, sticky='w')
breathe_off_mode.bind('<<ComboboxSelected>>', lambda e: send_breathe_off())
breathe_off_mode['values'] = ['Unique', 'Modulate']
breathe_off_mode.current(1)

# BREATH_OFF_RATE
def update_breathe_off_rate(prescale):
    global breathe_off_rate

    cur = breathe_off_rate.current()
    breathe_off_rate['values'] = ['%.3f s' % ((i + 1) / (12000000 / prescale / 256 / 32)) for i in range(16)]
    breathe_off_rate.current(cur)

tk.Label(timing, text='Breathe OFF Rate').grid(row=8, column=0, sticky='w')
breathe_off_rate = ttk.Combobox(timing, state='readonly', width=7)
breathe_off_rate.grid(row=8, column=1, sticky='w')
breathe_off_rate.bind('<<ComboboxSelected>>', lambda e: send_breathe_off())
breathe_off_rate['values'] = ['' for i in range(16)]
breathe_off_rate.current(7)

# PWM_RANGE
tk.Label(timing, text='PWM Range Extended').grid(row=9, column=0, sticky='w')
pwm_range = tk.IntVar()
tk.Checkbutton(timing, variable=pwm_range, command=send_breathe_off, onvalue=1, offvalue=0).grid(row=9, column=1, sticky='w')

update_prescale()

top.mainloop()
