#include "xparameters.h"
#include "xil_cache.h"
#include "xio.h"
#include "xuartlite.h"
#include "sleep.h"
#include "xaxidma.h"
#include "sleep.h"

u32 checkHalted(u32 baseAddr, u32 offset);

int main()
{
///////////////////////uart
	u8* imageData=XPAR_BRAM_0_BASEADDR;
	u32 receivedBytesNum=0;
	u32 totalReceivedBytesNum=0;
	u32 status=0;
	u32 imageSize = 158;
	u32 headerSize= 71;
	XUartLite_Config* myUartConfig= XUartLite_LookupConfig(XPAR_AXI_UARTLITE_0_DEVICE_ID);
	XUartLite myUart;
	status = XUartLite_CfgInitialize(&myUart,myUartConfig, myUartConfig->RegBaseAddr);
	if(status != XST_SUCCESS)
		xil_printf("Uart init failed\n");
	//read image from uart interface
	while(totalReceivedBytesNum < imageSize)
	{
		receivedBytesNum = XUartLite_Recv(&myUart,imageData+(sizeof(u8)*totalReceivedBytesNum),imageSize);
		totalReceivedBytesNum += receivedBytesNum;
	}
	//read image from memory
//	u8 img[]={0x42, 0x4D, 0x9E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3E, 0x00, 0x00, 0x00, 0x28, 0x00, 0x00, 0x00, 0x1D, 0x00, 0x00, 0x00, 0x18, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x60, 0x00, 0x00, 0x00, 0xC4, 0x0E, 0x00, 0x00, 0xC4, 0x0E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xF8, 0xFF, 0xFF, 0xFF, 0xF8, 0xFF, 0xFF, 0xFF, 0xF8, 0xFF, 0xFF, 0xFF, 0x38, 0xFF, 0xFF, 0xFF, 0x78, 0xFF, 0xFF, 0xFF, 0xF8, 0xFF, 0xFF, 0xEF, 0xF8, 0xFF, 0xFF, 0xEF, 0xF8, 0xFC, 0x07, 0xFB, 0xF8, 0xE0, 0x7F, 0xF1, 0xF8, 0xE1, 0xFF, 0x91, 0xF8, 0x80, 0x3F, 0xA0, 0xF8, 0x00, 0x1F, 0x01, 0xF8, 0x00, 0x0F, 0x03, 0xF8, 0x00, 0x0E, 0x13, 0xF8, 0x00, 0x18, 0x1F, 0xF8, 0x00, 0x00, 0x0F, 0xF8, 0x80, 0x00, 0x63, 0xF8, 0xC0, 0x00, 0x23, 0xF8, 0xF1, 0x58, 0x03, 0xF8, 0xF9, 0xFC, 0x0F, 0xF8, 0xFC, 0xE8, 0x1F, 0xF8, 0xFE, 0x00, 0x7F, 0xF8, 0xFF, 0x07, 0xFF, 0xF8};
//	for(int i=0;i<imageSize;i++)
//	{
//		XIo_Out8(imageData,img[i]);
//		imageData++;
//	}
//	imageData = XPAR_BRAM_0_BASEADDR;
///////////////////////dma
	XAxiDma_Config * myDmaConfig;
	XAxiDma myDma;
	myDmaConfig = XAxiDma_LookupConfigBaseAddr(XPAR_AXI_DMA_0_BASEADDR);
	status = XAxiDma_CfgInitialize(&myDma,myDmaConfig);
	if(status != XST_SUCCESS)
	{
		xil_printf("DMA Init Failed\n");
		return -1;
	}
	//xil_printf("DMA Init Success\n");

	status = checkHalted(XPAR_AXI_DMA_0_BASEADDR,0x4);
	//xil_printf("Status before data transfer %d\n",status);

	//Xil_DCacheFlushRange((u32)a,8*sizeof(u32)); //PS part
	status = XAxiDma_SimpleTransfer(&myDma,imageData+(headerSize*sizeof(u8)),(imageSize)*sizeof(u8),XAXIDMA_DEVICE_TO_DMA);
	if(status != XST_SUCCESS)
	{
		xil_printf("1- DMA Transfer Failed\n");
		return -1;
	}

	status = XAxiDma_SimpleTransfer(&myDma,imageData+(headerSize*sizeof(u8)),(imageSize)*sizeof(u8),XAXIDMA_DMA_TO_DEVICE);
	if(status != XST_SUCCESS)
	{
		xil_printf("2- DMA Transfer Failed\n");
		return -1;
	}

	status = checkHalted(XPAR_AXI_DMA_0_BASEADDR,0x4);
	while(status != 1)
	{
		status = checkHalted(XPAR_AXI_DMA_0_BASEADDR,0x4);
	}
	status = checkHalted(XPAR_AXI_DMA_0_BASEADDR,0x34);
	while(status != 1)
	{
		status = checkHalted(XPAR_AXI_DMA_0_BASEADDR,0x34);
	}

//	while ((XAxiDma_Busy(&myDma,XAXIDMA_DEVICE_TO_DMA)) ||
//		(XAxiDma_Busy(&myDma,XAXIDMA_DMA_TO_DEVICE))) {
//		xil_printf("w.\n")	;
//	}
	//xil_printf("DMA Transfer Succcess\n");

	//send image bytes to uart interface
	u32 totalSentBytesNum=0;
	u32 sentBytesNum=0;
	while(totalSentBytesNum < imageSize)
	{
		sentBytesNum = XUartLite_Send(&myUart,imageData+(sizeof(u8)*totalSentBytesNum),imageSize);
		totalSentBytesNum += sentBytesNum;
	}
}
u32 checkHalted(u32 baseAddr,u32 offset)
{
	u32 status;
	status = XAxiDma_ReadReg(baseAddr,offset) & XAXIDMA_HALTED_MASK;
	return status;
}
