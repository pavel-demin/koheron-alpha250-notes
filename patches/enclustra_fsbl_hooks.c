#include "xemacps.h"

#include "I2cInterface.h"
#include "InterruptController.h"
#include "ModuleEeprom.h"
#include "TimerInterface.h"

EN_RESULT InitaliseSystem()
{
    EN_RETURN_IF_FAILED(InitialiseI2cInterface());
    EN_RETURN_IF_FAILED(SetupInterruptSystem());
    return EN_SUCCESS;
}

u32 ConfigEthPhy()
{
    XEmacPs EmacPsInstance;
    XEmacPs *EmacPsInstancePtr = (XEmacPs*) &EmacPsInstance;
    int Status;
    u16 PhyData, PhyAddr, PhyType;
    XEmacPs_Config *Config;
    volatile int i;

    uint32_t serialNumber;
    ProductNumberInfo_t productNumberInfo;
    uint8_t macAddress[6];
    char EmacPsMAC[6];
    int MacAddrSet = 0;

    if (EN_FAILED(InitaliseSystem()))
    {
        return -1;
    }

    // Initialise the EEPROM.
    if (EN_SUCCEEDED(Eeprom_Initialise()))
    {
        // Read the EEPROM.
        if (EN_SUCCEEDED(Eeprom_Read()))
        {
            // After reading the EEPROM, the information is stored in its own translation unit - we can
            // query it using the EEPROM API functions.
            if (EN_SUCCEEDED(Eeprom_GetModuleInfo(&serialNumber, &productNumberInfo, (uint64_t*)&macAddress)))
            {
                EmacPsMAC[0] = macAddress[5];
                EmacPsMAC[1] = macAddress[4];
                EmacPsMAC[2] = macAddress[3];
                EmacPsMAC[3] = macAddress[2];
                EmacPsMAC[4] = macAddress[1];
                EmacPsMAC[5] = macAddress[0];
                MacAddrSet = 1;
            }
        }
    }
    if (MacAddrSet == 0)
    {
        EmacPsMAC[0] = 0x00;
        EmacPsMAC[1] = 0x0a;
        EmacPsMAC[2] = 0x35;
        EmacPsMAC[3] = 0x01;
        EmacPsMAC[4] = 0x02;
        EmacPsMAC[5] = 0x03;
    }


    Config = XEmacPs_LookupConfig(XPAR_XEMACPS_0_DEVICE_ID);

    Status = XEmacPs_CfgInitialize(EmacPsInstancePtr, Config, Config->BaseAddress);
    if (Status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }

    /*
     * Set the MAC address
     */
    Status = XEmacPs_SetMacAddress(EmacPsInstancePtr, EmacPsMAC, 1);
    if (Status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }

    XEmacPs_SetMdioDivisor(EmacPsInstancePtr, MDC_DIV_224);

    // detect PHY
    PhyAddr = 3;
    XEmacPs_PhyRead(EmacPsInstancePtr, PhyAddr, 0x3, (u16*)&PhyData);  // read value
    PhyType = (PhyData >> 4);

    // enabling RGMII delays
    if (PhyType == 0x162) // KSZ9031
    {
        //Ctrl Delay
        u16 RxCtrlDelay=7; // 0..15, default 7
        u16 TxCtrlDelay=7; // 0..15, default 7
        XEmacPs_PhyWrite(EmacPsInstancePtr, PhyAddr, 0xD, 0x0002);
        XEmacPs_PhyWrite(EmacPsInstancePtr, PhyAddr, 0xE, 0x0004); // Reg 0x4
        XEmacPs_PhyWrite(EmacPsInstancePtr, PhyAddr, 0xD, 0x4002);
        XEmacPs_PhyWrite(EmacPsInstancePtr, PhyAddr, 0xE, (TxCtrlDelay+(RxCtrlDelay<<4)));
        //Data Delay
        u16 RxDataDelay=7; // 0..15, default 7
        u16 TxDataDelay=7; // 0..15, default 7
        XEmacPs_PhyWrite(EmacPsInstancePtr, PhyAddr, 0xD, 0x0002);
        XEmacPs_PhyWrite(EmacPsInstancePtr, PhyAddr, 0xE, 0x0005); // Reg 0x5
        XEmacPs_PhyWrite(EmacPsInstancePtr, PhyAddr, 0xD, 0x4002);
        XEmacPs_PhyWrite(EmacPsInstancePtr, PhyAddr, 0xE, (RxDataDelay+(RxDataDelay << 4)+(RxDataDelay << 8)+(RxDataDelay << 12)));
        XEmacPs_PhyWrite(EmacPsInstancePtr, PhyAddr, 0xD, 0x0002);
        XEmacPs_PhyWrite(EmacPsInstancePtr, PhyAddr, 0xE, 0x0006); // Reg 0x6
        XEmacPs_PhyWrite(EmacPsInstancePtr, PhyAddr, 0xD, 0x4002);
        XEmacPs_PhyWrite(EmacPsInstancePtr, PhyAddr, 0xE, (TxDataDelay+(TxDataDelay << 4)+(TxDataDelay << 8)+(TxDataDelay << 12)));
        //Clock Delay
        u16 RxClockDelay=31; // 0..31, default 15
        u16 TxClockDelay=31; // 0..31, default 15
        XEmacPs_PhyWrite(EmacPsInstancePtr, PhyAddr, 0xD, 0x0002);
        XEmacPs_PhyWrite(EmacPsInstancePtr, PhyAddr, 0xE, 0x0008); // Reg 0x8 RGMII Clock Pad Skew
        XEmacPs_PhyWrite(EmacPsInstancePtr, PhyAddr, 0xD, 0x4002);
        XEmacPs_PhyWrite(EmacPsInstancePtr, PhyAddr, 0xE, (RxClockDelay+(TxClockDelay<<5)));
    }
    else if (PhyType == 0x161) // KSZ9021
    {
        XEmacPs_PhyWrite(EmacPsInstancePtr, PhyAddr, 0xB, 0x8104); // write Reg 0x104
        XEmacPs_PhyWrite(EmacPsInstancePtr, PhyAddr, 0xC, 0xF0F0); // set write data
        XEmacPs_PhyWrite(EmacPsInstancePtr, PhyAddr, 0xB, 0x8105); // write Reg 0x105
        XEmacPs_PhyWrite(EmacPsInstancePtr, PhyAddr, 0xC, 0x0000); // set write data
    }

    // Issue a reset to phy
    Status = XEmacPs_PhyRead(EmacPsInstancePtr, PhyAddr, 0x0, &PhyData);
    PhyData |= 0x8000;
    Status = XEmacPs_PhyWrite(EmacPsInstancePtr, PhyAddr, 0x0, PhyData);
    SleepMilliseconds(1);
    Status |= XEmacPs_PhyRead(EmacPsInstancePtr, PhyAddr, 0x0, &PhyData);

    if (Status != XST_SUCCESS)
    {
        return -1;
    } else {
        return 0;
    }
}
