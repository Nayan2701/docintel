FROM mcr.microsoft.com/devcontainers/python:1-3.12-bookworm

# The base image ships a Yarn apt repo whose signing key is out of date.
# apt-get update fails on any unverifiable repo, which breaks every feature
# that installs packages. We don't use Yarn, so remove the repo.
RUN grep -l "dl.yarnpkg.com" /etc/apt/sources.list.d/* 2>/dev/null | xargs -r rm -f \
    && rm -f /etc/apt/sources.list.d/yarn.list
