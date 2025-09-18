;; mindfck.asm: Copyright (C) 2025 Azorfus <azorfus@gmail.com>
;; Licensed under the terms of the GNU General Public License, either
;; version 2 or (at your option) any later version.

BITS 64

;; The norm for brainf*ck compilers and interpreters to provide a data area of 30,000 bytes.
%define arraysize	30000

;; These are our .text and .data segments. Nasm would usually provide us with these sections with the
;; "section .text" and "section .data" directives, but since this is a flat binary we construct them ourselves.
%define TEXTORG 0x00400000      ; Standard ELF base address (used by ld)
%define DATAOFFSET 0x2000
%define DATAORG (TEXTORG + DATAOFFSET)

;; Beginning of the file image...

        org TEXTORG


;; Beginning of the ELF header.

        db 0x7F, "ELF"           ; ehdr.e_ident

;; 64-bit ELF Header (ehdr) layout and field sizes:
;;   Offset  Size  Field         Description
;;   ------  ----  ------------  -----------------------------------------------------
;;   0x00    16    e_ident       ELF identification bytes (magic, class, data, version, OS ABI, ABI version, padding)
;;   0x10    2     e_type        Object file type (e.g., executable, shared object)
;;   0x12    2     e_machine     Target architecture (e.g., x86-64)
;;   0x14    4     e_version     ELF specification version
;;   0x18    8     e_entry       Virtual address of entry point
;;   0x20    8     e_phoff       File offset to program header table
;;   0x28    8     e_shoff       File offset to section header table
;;   0x30    4     e_flags       Processor-specific flags
;;   0x34    2     e_ehsize      Size of ELF header in bytes
;;   0x36    2     e_phentsize   Size of one entry in the program header table
;;   0x38    2     e_phnum       Number of entries in the program header table
;;   0x3A    2     e_shentsize   Size of one entry in the section header table
;;   0x3C    2     e_shnum       Number of entries in the section header table
;;   0x3E    2     e_shstrndx    Section header string table index

;; 64-bit Program Header (phdr) layout and field sizes:
;;   Offset  Size  Field         Description
;;   ------  ----  ------------  -----------------------------------------------------
;;   0x00    4     p_type        Segment type (e.g., PT_LOAD)
;;   0x04    4     p_flags       Segment flags (read, write, execute)
;;   0x08    8     p_offset      Offset of segment in the file
;;   0x10    8     p_vaddr       Virtual address of segment in memory
;;   0x18    8     p_paddr       Physical address (usually ignored)
;;   0x20    8     p_filesz      Size of segment in the file
;;   0x28    8     p_memsz       Size of segment in memory
;;   0x30    8     p_align       Alignment of segment in memory

;; In minimal flat binaries, the ELF header and program header table are placed at the very start of the file.
;; To save space, some fields that are not required by the loader (such as e_shoff, e_flags, section header fields)
;; may be reused to store program code or data. The program header table typically follows immediately after the ELF header,
;; and in some cases, the last bytes of the ELF header and the first bytes of the program header table may overlap
;; (e.g., sharing padding or unused fields).


;; Some of the program code is interleaved with the ELF header to save on space and reduce
;; the size of the binary.