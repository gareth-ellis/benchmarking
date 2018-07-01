#!/bin/bash
function mandatory() {
    if [ -z "${!1}" ]; then
        echo "${1} not set"
        usage
        exit
    fi
}

function optional() {
    if [ -z "${!1}" ]; then
        echo -n "${1} not set (ok)"
        if [ -n "${2}" ]; then
            echo -n ", default is: ${2}"
            export ${1}="${2}"
        fi
        echo ""
    fi
}
function usage(){
echo "Usage:"

echo "Time the each benchmark in the benchmarking repo"
echo "CATEGORY = a category of tests to run - folders in benchmark. Defaults to all"
echo "BRANCH = the branch the benchmarks to be timed are in. Defaults to master"
echo "RUNS = defaults to 1"
echo "FILTER = defaults to empty"

}
start=`date +%s`
getMACHINE_THREADS=`cat /proc/cpuinfo |grep processor|tail -n1|awk {'print $3'}`
let getMACHINE_THREADS=getMACHINE_THREADS+1 #getting threads this way is 0 based. Add one
optional MACHINE_THREADS $getMACHINE_THREADS
optional CATEGORY 
optional RUNS  1
optional FILTER
optional BRANCH master
rm -rf node
git clone http://github.com/nodejs/node.git
cd node
git checkout $BRANCH
lastCommit=`git log --format="%H" -n 1`
./configure  > ../node-master-build.log
make -j${MACHINE_THREADS}  >> ../node-master-build.log 2>&1
mv out/Release/node ./node
if [ $? -eq 0 ]; then
	echo "Build succesful at $lastCommit"
	node -v
else
	echo "Build failed. Check ../node-master-build.log"
fi
	

if [ -n "$FILTER" ]; then
	FILTER="--filter ${FILTER}"
fi
if [ -n "$RUNS" ]; then
	RUNS="--runs ${RUNS}"
fi
postbuild=`date +%s`
# run benchmark
fileName=output${CATEGORY}-`date +%d%m%y-%H%M%S`.csv
echo "Output will be saved to $fileName"
pwd
./node benchmark/run.js $FILTER $RUNS --format csv -- $CATEGORY | tee $fileName
cat $fileName | awk -f summariseCSV.awk
mv $fileName $startDir
scriptend=`date +%s`
let buildTime = $postBuild - $start
let postbuildTime = $scriptend - $postBuild
echo "Build took $buildTime seconds"
echo "Benchmark took $ipostbuildiTime seconds"
