import pyvisa as visa
from tkinter import *
from tkinter import ttk
window = Tk()
window.title("Простейшая настройка генератора")
#window.geometry('500x500')

window['background'] = 'grey'
def switchButtonStateRF():
    global FreqOnOff
    if buttonRF['bg'] == "red":
        buttonRF['bg'] = "green"
        buttonRF['fg'] = "white"
        FreqOnOff = True
    else:
        buttonRF['bg'] = "red"
        buttonRF['fg'] = "white"
        FreqOnOff = False
    N5182B.write(':OUTPut:STATe %d' % (FreqOnOff))
def switchButtonStateMOD():
    global ModOnOff
    N5182B.write(':OUTPut:MODulation:STATe %d' % (ModOnOff))
    if buttonMOD['bg'] == "red":
        buttonMOD['bg'] = "green"
        buttonMOD['fg'] = "white"
        ModOnOff = False
    else:
        buttonMOD['bg'] = "red"
        buttonMOD['fg'] = "white"
        ModOnOff = True

def callbackFuncFREQ(event):
    global Freq1
    N5182B.write(':SOURce:FREQuency:CW %G' % (Freq1))
    if comboFREQ['values'] == "Ghz":
        Freq1 = int(txt_freq.get()) * 1e9
    if comboFREQ['values'] == "MHz":
        Freq1 = int(txt_freq.get()) * 1e6
    if comboFREQ['values'] == "kHz":
        Freq1 = int(txt_freq.get()) * 1e3
    if comboFREQ['values'] == "Hz":
        Freq1 = int(txt_freq.get())

def callbackFuncAMP(event):
    global AMP1, AMP2
    N5182B.write(':SOURce:POWer:LEVel:IMMediate:AMPLitude %G V' % (AMP2))
    N5182B.write(':SOURce:POWer:LEVel:IMMediate:AMPLitude %G DBM' % (AMP1))
    if comboAMP['values'] == "dBm":
        AMP1 = int(txt_amp.get())
    if comboAMP['values'] == "V":
        AMP2 = int(txt_amp.get())

comboFREQ = ttk.Combobox(window,
                            values=[" ",
                                "GHz",
                                "MHz",
                                "kHz",
                                "Hz"])
comboFREQ.grid(column=2, row=3)

comboFREQ.bind("<<ComboboxSelected>>", callbackFuncFREQ)
comboFREQ.current(0)

comboAMP = ttk.Combobox(window,
                            values=[
                                "dBm",
                                "V"])
comboAMP.grid(column=2, row=4)
comboAMP.current(0)
comboAMP.bind("<<ComboboxSelected>>", callbackFuncAMP)


buttonRF = Button(window, text="RF on/off", bg="red", fg="white", width=25, command=switchButtonStateRF)
buttonRF.grid(column=1, row=5)

buttonMOD = Button(window, text="MOD on/off", bg="red", fg="white", width=25, command=switchButtonStateMOD)
buttonMOD.grid(column=1, row=6)


#надписи на инетфейсе
lbl_name_keysigt = Label(window, text="Keysight", font=("Arial Bold", 40), width=10, bg="grey", fg="white")
lbl_name_keysigt.grid(column=0, row=0)
lbl_name_keysigt = Label(window, text="N5182B", font=("Arial Bold", 40), width=10, bg="grey", fg="white")
lbl_name_keysigt.grid(column=0, row=1)

lbl_name_parametr = Label(window, text="Изменяемый параметр", font=("Arial Bold", 15), bg="grey", fg="white")
lbl_name_parametr.grid(column=0, row=2)
lbl_name_change = Label(window, text="Ввод значения", font=("Arial Bold", 15), bg="grey", fg="white")
lbl_name_change.grid(column=1, row=2)
lbl_name_current = Label(window, text="Текущее значение", font=("Arial Bold", 15), bg="grey", fg="white")
lbl_name_current.grid(column=(1), row=0)

lbl_Freq = Label(window, text="Чатстота, Hz", font=("Arial Bold", 15), width=25, height=1, bg="white", fg="red")
lbl_Freq.grid(column=0, row=3, sticky="nsew")
lbl_Freq_current = Label(window, text="6000000000, Hz", font=("Arial Bold", 15), fg="green", borderwidth="5", relief="sunken")
lbl_Freq_current.grid(column=1, row=1, sticky="nsew")

lbl_Ampl = Label(window, text="Амплитуда, dBm", font=("Arial Bold", 15), width=25, height=1, bg="red", fg="white")
lbl_Ampl.grid(column=0, row=4, sticky="nsew")
lbl_Ampl_current = Label(window, text="-144, dBm", font=("Arial Bold", 15), fg="green", borderwidth="5", relief="sunken")
lbl_Ampl_current.grid(column=2, row=1, sticky="nsew")

lbl_RFout = Label(window, text="Влючить излучение", font=("Arial Bold", 15), width=25, height=1, bg="white", fg="red")
lbl_RFout.grid(column=0, row=5, sticky="nsew")

lbl_Mod_OnOff = Label(window, text="Включить модуляцию", font=("Arial Bold", 15), width=25, height=1, bg="red", fg="white")
lbl_Mod_OnOff.grid(column=0, row=6, sticky="nsew")


txt_freq = Entry(window)
txt_freq.grid(column=1, row=3, sticky="nsew")
txt_amp = Entry(window)
txt_amp.grid(column=1, row=4, sticky="nsew")

FreqOnOff = 0
ModOnOff = 0
Freq1 = 1 * 1e9

rm = visa.ResourceManager()
N5182B = rm.open_resource('USB0::0x0957::0x1F01::MY59100704::0::INSTR')
N5182B.timeout = 10000
N5182B.write(':OUTPut:STATe %d' % (FreqOnOff))
N5182B.write(':OUTPut:MODulation:STATe %d' % (ModOnOff))

idn = N5182B.query('*IDN?')
N5182B.write('*RST')
opt = N5182B.query('*OPT?')
temp_values = N5182B.query_ascii_values('*OPC?')
opc = int(temp_values[0])

window.mainloop()