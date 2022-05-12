#include "xaxidma.h"
#include "xparameters.h"
#include "sleep.h"
#include "xil_cache.h"
#include "xio.h"
#include "xuartlite.h"

u32 checkHalted(u32 baseAddr, u32 offset);

int main()
{
////	u32 a[]={1,2,3,4,5,6,7,8};
////	u32 b[8];
//	u8 a = XPAR_BRAM_0_BASEADDR;
//	u8 b = XPAR_BRAM_0_BASEADDR + 8*sizeof(u8);
//
//	for(int i=0;i<8;i++)
//	{
//		XIo_Out8(a,i+1);
//		a += 1;
//	}
//	a = XPAR_BRAM_0_BASEADDR;
//
//
///////////////////////uart

	u8* imageData=XPAR_BRAM_0_BASEADDR;
	u32 receivedBytesNum=0;
	u32 totalReceivedBytesNum=0;
	u32 status=0;
	u32 fileSize = 16;
	XUartLite_Config* myUartConfig= XUartLite_LookupConfig(XPAR_AXI_UARTLITE_0_DEVICE_ID);
	XUartLite myUart;
	status = XUartLite_CfgInitialize(&myUart,myUartConfig, myUartConfig->RegBaseAddr);
	if(status != XST_SUCCESS)
		xil_printf("Uart init failed\n");
	while(totalReceivedBytesNum < fileSize)
	{
		receivedBytesNum = XUartLite_Recv(&myUart,imageData+(sizeof(u8)*totalReceivedBytesNum),fileSize);
		totalReceivedBytesNum += receivedBytesNum;
	}
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
	xil_printf("D.I.S\n");

	status = checkHalted(XPAR_AXI_DMA_0_BASEADDR,0x4);
	//xil_printf("Status before data transfer %d\n",status);
	xil_printf("S.B.T %d\n",status);

	//	Xil_DCacheFlushRange((u32)a,8*sizeof(u32)); //PS part
	status = XAxiDma_SimpleTransfer(&myDma,imageData,fileSize*sizeof(u8),XAXIDMA_DMA_TO_DEVICE);
	if(status != XST_SUCCESS)
	{
		xil_printf("DMA Transfer Failed\n");
		return -1;
	}
	status = XAxiDma_SimpleTransfer(&myDma,imageData,fileSize*sizeof(u8),XAXIDMA_DEVICE_TO_DMA);
	if(status != XST_SUCCESS)
	{
		xil_printf("DMA Transfer Failed\n");
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
//		xil_printf("w.\n");
//	}
	//xil_printf("DMA Transfer Succcess\n");
	xil_printf("D.T.S\n");
	for(int i=0;i<fileSize;i++)
	{
		xil_printf("%0X\n",XIo_In8(imageData));
		imageData+=1;
	}
}
u32 checkHalted(u32 baseAddr,u32 offset)
{
	u32 status;
	status = XAxiDma_ReadReg(baseAddr,offset) & XAXIDMA_HALTED_MASK;
	return status;
}
