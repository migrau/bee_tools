// This file is a part of MikheyevLab/bee_tools. License is MIT

#include "DeckLinkAPI.h"
#include "DeckLinkAPIDispatch.cpp"
#include "DeckLinkAPIVersion.h"

#include <iostream>
#include <cstdlib>

#include "bmd/callback.hpp"

int main(int argc, char *argv[]) {
  IDeckLinkIterator *deckLinkIterator = CreateDeckLinkIteratorInstance();

  if (deckLinkIterator == NULL) {
    std::cerr << "Failed to open DeckLink driver";
    return -1;
  }

  // Check all DeckLink devices
  IDeckLink* deckLink;
  char* name;
  HRESULT resultCode;

  resultCode = deckLinkIterator->Next(&deckLink);

  while (resultCode == S_OK) {
    if (deckLink->GetDisplayName((const char **) &name) == S_OK) {
      std::cout << "Found device: " <<  name << "\n";
    }

    // free device name
    std::free(name);

    // TODO: Handoff to thread for multiplex input
    // Release deckLink device
    // deckLink->Release();

    // Get the next device
    // resultCode = deckLinkIterator->Next(&deckLink);
    resultCode = S_FALSE;
  }

  if (resultCode == E_FAIL) {
    std::cerr << "Failed to acquire DeckLink device";
    return -1;
  }

  // Establish input
  IDeckLinkInput* input;
  if (deckLink->QueryInterface(IID_IDeckLinkInput, (void**) &input) == E_NOINTERFACE) {
    std::cerr << "Could not acquire input interface.";
    return -1;
  }

  // Get available modes
  IDeckLinkDisplayModeIterator* modes;
  if (input->GetDisplayModeIterator(&modes) == E_FAIL) {
    std::cerr << "Failed to get display modes";
    return -1;
  }

  //Get mode
  IDeckLinkDisplayMode* mode;
  resultCode = modes->Next(&mode);

  BMDDisplayMode displayMode;
  BMDPixelFormat pixelFormat = bmdFormat10BitYUV;
  BMDVideoInputFlags flags;

  // iterate over available modes to get the appropriate flags
  while (resultCode == S_OK && mode != NULL) {
    mode->GetName((const char**) &name);
    std::cout << "Mode: " << name << " ";
    std::cout << "w: " << mode->GetWidth() << " h: " << mode->GetHeight();

    // get frame rate
    BMDTimeValue timeValue; // long
    BMDTimeScale timeScale; // long

    if (mode->GetFrameRate(&timeValue, &timeScale) == S_OK) {
      std::cout << " fps: " << timeScale/timeValue;
    }

    std::cout << "\n";

    displayMode = mode->GetDisplayMode();

    // Manually set mode for now
    if(displayMode == bmdMode4K2160p30) {
      resultCode = S_FALSE;
    }

    flags = mode->GetFlags();

    std::free(name);
    resultCode = modes->Next(&mode);
  }

  BMDDisplayModeSupport support;
  IDeckLinkDisplayMode* resultDisplayMode;
  if (input->DoesSupportVideoMode(displayMode, pixelFormat, flags, &support, &resultDisplayMode) == E_FAIL) {
    std::cerr << "Something went wrong while testing the video mode";
    return -1;
  }

  // Check if display mode is supported
  if (support == bmdDisplayModeNotSupported) {
    std::cerr << "Display mode is not supported";
    return -1;
  } else if (support == bmdDisplayModeSupportedWithConversion) {
    std::cerr << "Display mode only supported with conversion, Carrying on!";
  }

  // Configure video device
  resultCode = input->EnableVideoInput(displayMode, pixelFormat, flags);

  if (resultCode == E_FAIL) {
    std::cerr << "Failed to enable video input";
    return -1;
  } else if (resultCode == E_INVALIDARG) {
    std::cerr << "Could not enable video input. Reason: Invalid argument";
    return -1;
  } else if (resultCode == E_ACCESSDENIED) {
    std::cerr << "Could not enable video input. Reason: Access denied";
    return -1;
  } else if (resultCode == E_OUTOFMEMORY) {
    std::cerr << "Could not enable video input. Reason: Out of memory";
    return -1;
  }

  // Set callback
  BMDCallback callback = BMDCallback();
  if (input->SetCallback(&callback) == E_FAIL) {
    std::cerr << "Failed to set callback";
    return -1;
  }

  // Start streams
  // TODO: check errorCodes
  resultCode = input->StartStreams();

  // Stop streams
  if (input->StopStreams() == E_ACCESSDENIED) {
    std::cerr << "Streams already stopped\n";
  }

  //TODO: Proper Cleanup
  input->DisableVideoInput();
  input->Release();
  deckLink->Release();
  return 0;
}
