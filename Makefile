ARCH            = $(shell uname -m | sed s,i[3456789]86,ia32,)

PROJECT_NAME = hello_world
OVMF = /usr/share/edk2-ovmf/x64/OVMF_CODE.fd

OBJS = main.o
TARGET = $(PROJECT_NAME).efi

EFIINC          = /usr/include/efi
EFIINCS         = -I$(EFIINC) \
				  -I$(EFIINC)/$(ARCH) \
				  -I$(EFIINC)/protocol
LIB             = /usr/lib
EFILIB          = /usr/lib
EFI_CRT_OBJS    = $(EFILIB)/crt0-efi-$(ARCH).o
EFI_LDS         = $(EFILIB)/elf_$(ARCH)_efi.lds

CFLAGS          = $(EFIINCS) \
				  -fno-stack-protector \
				  -fpic \
				  -fshort-wchar \
				  -Wall \
				  -Werror \
				  -O0
ifeq ($(ARCH),x86_64)
  CFLAGS += -DEFI_FUNCTION_WRAPPER
endif

LDFLAGS         = -nostdlib \
				  -znocombreloc \
				  -T $(EFI_LDS) \
				  -shared \
				  -Bsymbolic \
				  -L $(EFILIB) \
				  -L $(LIB) $(EFI_CRT_OBJS)

.PHONY: clean all

all: $(TARGET)

$(PROJECT_NAME).so: $(OBJS)
	ld $(LDFLAGS) $(OBJS) -o $@ -lefi -lgnuefi

$(OBJS):%.o:%.c

%.efi: %.so
	objcopy -j .text \
		-j .sdata \
		-j .data \
		-j .dynamic \
        -j .dynsym \
		-j .rel \
		-j .rela \
		-j .reloc \
        --target=efi-app-$(ARCH) \
		--subsystem=10 \
		$^ $@

qemu: $(TARGET)
	uefi-run -b $(OVMF) $(TARGET)

clean:
	rm $(TARGET) $(PROJECT_NAME).so $(OBJS)
