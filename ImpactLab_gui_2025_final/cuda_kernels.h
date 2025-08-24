// cuda_kernels.h
#pragma once

// Declara��o da fun��o wrapper que ser� chamada pelo formul�rio.
// Ela gerencia a mem�ria e lan�a o kernel CUDA para o filtro S�pia.
void applySepiaFilterCuda(unsigned char* inputImage, unsigned char* outputImage, int width, int height, int stride);

// Declara��o da fun��o wrapper para o nosso novo filtro de Invers�o de Cores.
void applyInvertFilterCuda(unsigned char* inputImage, unsigned char* outputImage, int width, int height, int stride);