#include <efi.h>
#include <efilib.h>

EFI_STATUS EFIAPI efi_main(EFI_HANDLE image, EFI_SYSTEM_TABLE *sys_table)
{
	EFI_STATUS status;
	InitializeLib(image, sys_table);
	status = uefi_call_wrapper(sys_table->BootServices->SetWatchdogTimer, 4,
			0,
			0,
			0,
			NULL);
	if (status != EFI_SUCCESS) return status;
	status = uefi_call_wrapper(sys_table->ConOut->OutputString, 2,
                                        sys_table->ConOut,
                                        L"Hello, World!\n");
	if (status != EFI_SUCCESS) return status;
	return status;
}
