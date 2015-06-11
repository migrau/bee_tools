// This file is a part of MikheyevLab/bee_tools. License is MIT

#include "callback.hpp"

#include <iostream>

HRESULT BMDCallback::VideoInputFrameArrived(IDeckLinkVideoInputFrame *videoFrame, IDeckLinkAudioInputPacket *audioPacket) {
    std::cout << "Received frame\n";

    return S_OK;
}

HRESULT BMDCallback::VideoInputFormatChanged (BMDVideoInputFormatChangedEvents notificationEvents,
    IDeckLinkDisplayMode *newDisplayMode, BMDDetectedVideoInputFormatFlags detectedSignalFlags) {
    std::cout << "Received format change\n";
    std::cerr << "Can't handle format change\n";

    return E_FAIL;
}
