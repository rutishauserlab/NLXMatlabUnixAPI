#!/bin/sh
#
#this script compiles the code necessary to read neuralynx files from matlab.
#
# the first few lines are parameters that need to be adjusted (see README file).
#
#Version 12/05/11 urut/MPI
#updated 12/07/15 urut/Caltech
#updated 02/28/24 urut/Cedars. Added Mac Silicon

#== Should it compile for 32 or 64 bit matlab and which platform
PLATFORM="64AMAC"     #should be 32PC, 64PC, 32MAC (intel), 64MAC (intel), 64AMAC (silicon)

#== paths to matlab
#defaults for MAC
#INCLMATLAB="/Applications/MATLAB_R2009a.app/extern/include/"
#BINMATLAB="/Applications/MATLAB_R2009a.app/bin/"
INCLMATLAB="/Applications/MATLAB_R2023b.app/extern/include/"
BINMATLAB="/Applications/MATLAB_R2023b.app/bin/"

#defaults for Linux
#INCLMATLAB="/opt/MATLAB/R2014b/extern/include/"
#BINMATLAB="/opt/MATLAB/R2014b/bin/"


#=== no parameters below here
OUTDIR="../binaries/"
SRCDIR="source/"

CFLAGS_COMMON="-Wno-non-template-friend  -fpermissive -c"

rm $SRCDIR/compatibility.h

case $PLATFORM in
32PC)
    echo "Compiling the Linux 32-bit version"
    cp $SRCDIR/compatibility32.h $SRCDIR/compatibility.h
    CFLAGS="$CFLAGS_COMMON -fPIC"
    ;;
64PC)
    echo "Compiling the Linux 64-bit version"
    cp $SRCDIR/compatibility64.h $SRCDIR/compatibility.h
    CFLAGS="$CFLAGS_COMMON -fPIC -m64"
    ;;
32MAC)
    echo "Compiling the Mac OS X 32-bit version (intel)"
    cp $SRCDIR/compatibility32.h $SRCDIR/compatibility.h
    CFLAGS="$CFLAGS_COMMON -arch i386"
    ;;
64MAC)
    echo "Compiling the Mac OS X 64-bit version (intel)"
    cp $SRCDIR/compatibility64.h $SRCDIR/compatibility.h
    CFLAGS="$CFLAGS_COMMON -arch x86_64"
    ;;
64AMAC)
    echo "Compiling the Mac OS X 64-bit version (silicon)"
    cp $SRCDIR/compatibility64_new.h $SRCDIR/compatibility.h
    CFLAGS="-fpermissive -c -arch arm64 -x c++ -std=c++17 -Wno-unused-value -Wno-deprecated-declarations -Wno-comment"
    ;;
*)
    echo "Not a recognized platform"
    ;;
esac

cd $SRCDIR

CFILES="Nlx_Code.cpp TimeBuf.cpp TimeEventBuf.cpp FileDataBucket.cpp GeneralOperations.cpp ProcessorSpike.cpp ProcessorEV.cpp ProcessorCSC.cpp ProcessorVT.cpp TimeCSCBuf.cpp TimeMClustTSBuf.cpp TimeSEBuf.cpp TimeSTBuf.cpp TimeTSBuf.cpp TimeTTBuf.cpp TimeVideoBuf.cpp"
g++ $CFLAGS -I$INCLMATLAB $CFILES

echo "using flags: $CFLAGS"

#now make matlab binary
OFILES="FileDataBucket.o GeneralOperations.o Nlx_Code.o TimeBuf.o TimeEventBuf.o TimeCSCBuf.o TimeMClustTSBuf.o TimeSEBuf.o TimeSTBuf.o TimeTSBuf.o TimeTTBuf.o TimeVideoBuf.o"
$BINMATLAB/mex CXX_FLAGS='$CFLAGS -fpermissive -fPIC' -R2018a -output $OUTDIR/Nlx2MatEV_v3 Nlx2MatEV.cpp ProcessorEV.o $OFILES
$BINMATLAB/mex CXX_FLAGS='$CFLAGS -fpermissive -fPIC' -R2018a -output $OUTDIR/Nlx2MatCSC_v3 Nlx2MatCSC.cpp ProcessorCSC.o $OFILES
$BINMATLAB/mex CXX_FLAGS='$CFLAGS -fpermissive -fPIC' -R2018a -output $OUTDIR/Nlx2MatVT_v3 Nlx2MatVt.cpp ProcessorVT.o $OFILES
$BINMATLAB/mex CXX_FLAGS='$CFLAGS -fpermissive -fPIC' -R2018a -output $OUTDIR/Nlx2MatSpike_v3 Nlx2MatSpike.cpp ProcessorSpike.o $OFILES
$BINMATLAB/mex CXX_FLAGS='$CFLAGS -fpermissive -fPIC' -R2018a -output $OUTDIR/Mat2NlxCSC Mat2NlxCSC.cpp $OFILES
$BINMATLAB/mex CXX_FLAGS='$CFLAGS -fpermissive -fPIC' -R2018a -output $OUTDIR/Mat2NlxSE Mat2NlxSE.cpp $OFILES
$BINMATLAB/mex CXX_FLAGS='$CFLAGS -fpermissive -fPIC' -R2018a -output $OUTDIR/Mat2NlxTT Mat2NlxTT.cpp $OFILES
$BINMATLAB/mex CXX_FLAGS='$CFLAGS -fpermissive -fPIC' -R2018a -output $OUTDIR/Mat2NlxEV Mat2NlxEV.cpp $OFILES

cd ..

