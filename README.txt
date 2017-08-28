This is a simple Dockerfile for the
[Yices SMT solver](https://github.com/SRI-CSL/yices2).
Docker 17.05 or newer is needed to run this Dockerfile because it makes use of
multistage builds to keep the resulting image small (14 MB).
However, it could made even smaller by starting from `scratch` instead of
from `busybox`.

This Dockerfile is published under the BSD-3 licence.
Docker, Yices, polylib, and other content contained in the resulting image
are each subject to their own licences though.
