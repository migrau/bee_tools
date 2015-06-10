// This file is a part of MikheyevLab/bee_tools. License is MIT

#include "DeckLinkAPI.h"
#include "DeckLinkAPIDispatch.cpp"
#include "DeckLinkAPIVersion.h"

#include <iostream>
#include <cstdlib>

int main(int argc, char *argv[]) {
  IDeckLinkIterator *deckLinkIterator = CreateDeckLinkIteratorInstance();

  if (deckLinkIterator == NULL) {
    return -1;
  }

  // Check all DeckLink devices
  IDeckLink* deckLink;
  char* deviceName;
  HRESULT resultCode;

  resultCode = deckLinkIterator->Next(&deckLink);

  while (resultCode == S_OK) {
    if (deckLink->GetDisplayName((const char **) &deviceName) == S_OK) {
      std::cout << deviceName << "\n";
    }

    // free device name
    std::free(deviceName);

    //Release deckLink device
    deckLink->Release();

    // Get the next device
    resultCode = deckLinkIterator->Next(&deckLink);
  }

  if (resultCode == E_FAIL) {
    return -1;
  }

  return 0;
}
