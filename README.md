# biqa
Biometric Image Quality Assessment

A program based on existing code for quality assessing images and required metrics from the ISO/IEC 29794-6 2nd.
This is then run against an image database "imgdb" which contains links to the biometric images to perform analysis of.

find_iris
  goes through the image and finds a large ring (the iris), then it finds a smaller ring inside it (the pupil).
  returns coordinates and radius of both circles.
