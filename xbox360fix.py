#!/usr/bin/env python3
# ------------------------------------------------------------------------------------------------------------------------------
# Desc:Programa em python que lista, verifica e envia comandos para resolver um problema comum com controles genéricos no linux.
# Autor:Urasono
# Versão:1.0
#Retirado da wiki do ArchLinux: https://wiki.archlinux.org/title/Gamepad#Using_generic/clone_controllers

import usb.core

dev = usb.core.find(idVendor=0x045e, idProduct=0x028e)

if dev is None:
    raise ValueError('Device not found')
else:
    dev.ctrl_transfer(0xc1, 0x01, 0x0100, 0x00, 0x14)
