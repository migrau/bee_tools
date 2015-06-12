// This file is a part of MikheyevLab/bee_tools. License is MIT 

#include "DeckLinkAPI.h"

class BMDCallback : public IDeckLinkInputCallback {
  public:
    BMDCallback(){}
    ~BMDCallback(){}

    // Implements the IDeckLinkInputCallback interface
    HRESULT VideoInputFrameArrived(IDeckLinkVideoInputFrame *videoFrame, IDeckLinkAudioInputPacket *audioPacket);
    HRESULT VideoInputFormatChanged (BMDVideoInputFormatChangedEvents notificationEvents,
        IDeckLinkDisplayMode *newDisplayMode, BMDDetectedVideoInputFormatFlags detectedSignalFlags);

    // Implements the IUnkown Interface
    HRESULT QueryInterface(REFIID id, void **outputInterface) {
      return E_NOINTERFACE;
    }
    ULONG AddRef() {}
    ULONG Release() {};
};

void convertYUV2Gray(uint32_t* in, uint16_t* out, long height, long width);

