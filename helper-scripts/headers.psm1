function Get-Headers {
    $amadeusHeader = ".\ssa-cleanup-processing-files\templates\amadeusHeader.txt"
    $amadeus2Header = ".\ssa-cleanup-processing-files\templates\amadeus2Header.txt"
    $HttGGoSHeader = ".\ssa-cleanup-processing-files\templates\HttGGoSHeader.txt"
    $OPED1Header = ".\ssa-cleanup-processing-files\templates\OPED1Header.txt"
    $OPED2Header = ".\ssa-cleanup-processing-files\templates\OPED2Header.txt"
    $OPHoshiHeader = ".\ssa-cleanup-processing-files\templates\OPHoshiHeader.txt"
    $OPLyraHeader = ".\ssa-cleanup-processing-files\templates\OPLyraHeader.txt"
    $OPLyra2Header = ".\ssa-cleanup-processing-files\templates\OPLyra2Header.txt"
    $OPSOHeader = ".\ssa-cleanup-processing-files\templates\OPSOHeader.txt"

    return $OPED2Header,   # OVA
        $amadeusHeader,    # 1
        $OPED1Header,      # 2
        $OPED1Header,      # 3
        $OPED1Header,      # 4
        $OPED1Header,      # 5
        $OPED1Header,      # 6
        $OPED1Header,      # 7
        $OPLyraHeader,     # 8
        $OPED1Header,      # 9
        $OPED1Header,      # 10
        $OPED1Header,      # 11
        $OPHoshiHeader,    # 12
        $OPED1Header,      # 13
        $OPED2Header,      # 14
        $OPED2Header,      # 15
        $OPED2Header,      # 16
        $OPED2Header,      # 17
        $OPLyra2Header,    # 18
        $OPED2Header,      # 19
        $OPED2Header,      # 20
        $OPSOHeader,       # 21
        $amadeus2Header,   # 22
        $HttGGoSHeader     # 23
}
