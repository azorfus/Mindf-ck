;; mindfck.asm: Copyright (C) 2025 Azorfus <azorfus@gmail.com>
;; Licensed under the terms of the GNU General Public License, either
;; version 2 or (at your option) any later version.

BITS 64

;; The norm for brainf*ck compilers and interpreters to provide a data area of 30,000 bytes.
%define arraysize	30000

section .bss
    bfmemory: resb arraysize ; The reserved memory for brainf*ck to operate on

section .text
    global _start

_start:
