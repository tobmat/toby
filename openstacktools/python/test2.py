#!/usr/bin/env python
import sys

def main(test,test2):
  source = __import__(test)

  print source.tenant_name
  print test2

  print __name__

if __name__ == "__main__":
  main(sys.argv[1], sys.argv[2])