BEGIN {
  FS = ",";
  runningtotal=0;
}
{
  timetaken = $4;
  totalinseconds = totalinseconds + timetaken;
}
END {
  print "Total in seconds: " totalinseconds;
}
