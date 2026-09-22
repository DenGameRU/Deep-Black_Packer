# Deep Black Archive Packer (.pack)

A minimal, high-performance Delphi utility engineered to rebuild and re-compile folders of extracted game assets back into the proprietary `.pack` archive format (`GameGuiSceneSet.pack`) used by **Deep Black** (2011/2012).

## Features
- **Automated Directory Scanning:** Scans the selected input folder using native Windows file search blocks (`TSearchRec`) to index assets.
- **Dynamic Header Building:** Automatically counts separate extension frequencies and accurately populates the custom 24-byte main archive header.
- **Strict Byte-Sized Padding:** Formats extension identifiers into 4-byte records and cleans file path descriptors into precise 32-byte null-padded (`#0`) blocks.
- **Precise Offset Mapping:** Dynamically calculates file positions (`FileOffset`) before packing data to guarantee perfect alignment with the original file allocation table structure.
- **Safe Linear Buffering:** Streams bin clusters via array pointers (`FileBuffer[0]`) to ensure massive asset tables get compiled into memory without desyncing or causing memory corruption.

## Packing Logic Pipeline
The builder constructs the `.pack` container using the identical block pattern analyzed from the commercial runtime:
1. **Magic ID Injector:** Writes the initial format flag (`UWFPVF01`).
2. **Type Catalog Structure:** Compiles an index table containing file extensions mapped alongside their active file limits.
3. **Master Allocation Record:** Generates a linear chunk array holding resource sizes paired with target archive byte pointers.
4. **Binary Asset Injector:** Sequential file clusters are appended sequentially to match the master allocation references.

## Usage
1. Compile and launch the packer tool, then click the **PACK** button.
2. Select the target directory (e.g., `Extracted\`) containing your modified game texture elements (`*.dds`, `*.gui`).
3. Enter the desired name for your newly built file inside the file explorer window. The dialog manager will automatically enforce the `.pack` file extension wrapper.
4. Review the build completion log inside the frame console until the success message appears.

## Original Credits
Developed by **DenGame** (2026). Part of an open-source initiative to preserve classic game engine reverser tools.
