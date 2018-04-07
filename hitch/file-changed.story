File changed:
  based on: HitchBuild
  description: |
    For many builds (e.g. database, virtualenv), you will want
    to leave it be if it exists unless one or more source files have
    changed since the build was last run.
  given:
    files:
      sourcefile1.txt: |
        file that, if changed, should trigger a rebuild
      sourcefile2.txt: |
        file that, if changed, should trigger a rebuild
    setup: |
      from pathquery import pathquery
      import hitchbuild

      class Thing(hitchbuild.HitchBuild):
          def __init__(self, src_dir):
              self._src1 = self.from_source(
                  "firstsource",
                  pathquery(src_dir).named("sourcefile1.txt"),
              )
              self._src2 = self.from_source(
                  "secondsource",
                  pathquery(src_dir).named("sourcefile1.txt"),
              )
          
          @property
          def thingpath(self):
              return self.build_path/"thing.txt"

          def fingerprint(self):
              return self.thingpath.text()

          def build(self):
              self.thingpath.write_text("build triggered\n", append=True)
              self.thingpath.write_text(
                  "files changed: {0}\n".format(', '.join(self._src1.changes)),
                  append=True,
              )
              self.thingpath.write_text(
                  str("sourcefile1.txt" in self._src1.changes) + '\n',
                  append=True,
              )
              self.thingpath.write_text(
                  "files changed: {0}\n".format(', '.join(self._src2.changes)),
                  append=True,
              )
              self.thingpath.write_text(
                  str("sourcefile2.txt" in self._src2.changes) + '\n',
                  append=True,
              )
              

      build = Thing(src_dir=".").with_build_path(".")
  steps:
  - Run code: |
      build.ensure_built()
      build.ensure_built()

  - File contents will be:
      filename: thing.txt
      text: |
        build triggered
        files changed: /path/to/sourcefile1.txt
        True
        files changed: /path/to/sourcefile1.txt
        True
        build triggered
        files changed: 
        False
        files changed: 
        False

  - Sleep: 1 

  - Touch file: sourcefile.txt

  - Run code: |
      build.ensure_built()

  - File contents will be:
      filename: thing.txt
      text: |-
        build triggered
        files changed: /path/to/sourcefile1.txt
        True
        files changed: /path/to/sourcefile1.txt
        True
        build triggered
        files changed: 
        False
        files changed: 
        False
        build triggered
        files changed: 
        False
        files changed: 
        False
