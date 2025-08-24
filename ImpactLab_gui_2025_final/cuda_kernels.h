// cuda_kernels.h
#pragma once

// Declaração da função wrapper que será chamada pelo formulário.
// Ela gerencia a memória e lança o kernel CUDA para o filtro Sépia.
void applySepiaFilterCuda(unsigned char* inputImage, unsigned char* outputImage, int width, int height, int stride);

// Declaração da função wrapper para o nosso novo filtro de Inversão de Cores.
void applyInvertFilterCuda(unsigned char* inputImage, unsigned char* outputImage, int width, int height, int stride);