#!/usr/bin/env python3                          # ----------------------------------------------

import usb.core
import usb.util

VENDOR_ID = 0x045E
PRODUCT_ID = 0x028E


def listar_dispositivos():
    print("Dispositivos USB encontrados:\n")

    devices = list(usb.core.find(find_all=True))

    if not devices:
        print("Nenhum dispositivo USB encontrado.")
        return

    for dev in devices:
        print(f"  Vendor ID : {hex(dev.idVendor)}")
        print(f"  Product ID: {hex(dev.idProduct)}")

        try:
            fabricante = usb.util.get_string(dev, dev.iManufacturer)
            print(f"  Fabricante: {fabricante}")
        except usb.core.USBError:
            pass

        print("-" * 30)


def encontrar_dispositivo():
    return usb.core.find(idVendor=VENDOR_ID, idProduct=PRODUCT_ID)


def enviar_comando(dev):
    try:
        if dev.is_kernel_driver_active(0):
            dev.detach_kernel_driver(0)

        dev.set_configuration()
        dev.ctrl_transfer(0xC1, 0x01, 0x0100, 0x00, 0x14)

        print("Comando enviado com sucesso!")

    except usb.core.USBError as e:
        print(f"Erro na comunicação USB: {e}")


def main():
    listar_dispositivos()

    print("\nProcurando dispositivo específico...\n")

    dev = encontrar_dispositivo()

    if dev is None:
        print("Dispositivo não encontrado.")
        return

    print("Dispositivo encontrado! Enviando comando...\n")
    enviar_comando(dev)


if __name__ == "__main__":
    main()
