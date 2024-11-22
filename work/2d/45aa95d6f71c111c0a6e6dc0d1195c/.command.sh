#!/bin/bash -euo pipefail
echo "Processing S188428.bam with windows.1000kb.bed..."
fragment_extractor S188428.bam windows.1000kb.bed         output/S188428_fragments.bed         output/S188428_fragments.wig
