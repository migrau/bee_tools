// This file is a part of MikheyevLab/bee_tools. License is MIT

#include "callback.hpp"

#include <iostream>
#include <cstdlib>

#include <opencv2/opencv.hpp>
using namespace cv;
HRESULT BMDCallback::VideoInputFrameArrived(IDeckLinkVideoInputFrame *videoFrame, IDeckLinkAudioInputPacket *audioPacket) {
    long rowBytes = videoFrame->GetRowBytes();
    long width = videoFrame->GetWidth();
    long height = videoFrame->GetHeight();
    long size = rowBytes * height;

    std::cout << "Received frame";
    std::cout << " Height: " << height;
    std::cout << " Width: " << width;
    std::cout << " Size: " << size;
    std::cout << " PizelFormat: " << videoFrame->GetPixelFormat();
    std::cout << "\n";

    // videoFrame->GetBytes()  pointer is only valid as long frame is valid
    // 128byte alignment 
    // 12x10bit components in 4x32words little-endian
    void* frameData;
    if (videoFrame->GetBytes(&frameData) == E_FAIL) {
        std::cerr << "Could not access video frame data\n";
        return E_FAIL;
    }

    // Allocate greyscale image
    uint16_t* data = (uint16_t*) std::calloc(width * height, sizeof(*data));
    convertYUV2Gray((uint32_t*) frameData, data, height, width);

    // Create OpenCV matrix CV_16UC1
    Mat frame = Mat(width, height, CV_16UC1, data);

    free(data);
    frame->release();
    return S_OK;
}

HRESULT BMDCallback::VideoInputFormatChanged (BMDVideoInputFormatChangedEvents notificationEvents,
    IDeckLinkDisplayMode *newDisplayMode, BMDDetectedVideoInputFormatFlags detectedSignalFlags) {
    std::cout << "Received format change\n";
    std::cerr << "Can't handle format change\n";

    return E_FAIL;
}

/*
 * Converts an image in bmdFormat10BitYUV into U16Gray for OpenCV
 */
void convertYUV2Gray(uint32_t* in, uint16_t* out, long height, long width){
    size_t ind_in  = 0;
    size_t ind_out = 0; // Index for out

    while (ind_out < height*width) {

        // Load four words
        uint32_t w0 = in[ind_in];
        uint32_t w1 = in[ind_in + 1];
        uint32_t w2 = in[ind_in + 2];
        uint32_t w3 = in[ind_in + 3];

        // ((1 << 10) - 1) = 1023 copy the lower 10bit
        out[ind_out]     = (w0 >> 10) & 1023;
        out[ind_out + 1] = w1 & 1023;
        out[ind_out + 2] = (w1 >> 20) & 1023;
        out[ind_out + 3] = (w2 >> 10) & 1023;
        out[ind_out + 4] = w3 & 1023;
        out[ind_out + 5] = (w3 >> 20) & 1023;

        ind_in += 4;
        ind_out += 6;
    }
}
