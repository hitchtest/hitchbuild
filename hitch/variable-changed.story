Variable changed:
  based on: HitchBuild
  description: |
    Using HitchBuild you can feed an arbitrary variable into the
    build system and use it to determine whether or not to rebuild
    as well as how to rebuild.
    
    Some examples:
    
    - Building python virtualenv with a list of packages (all variables).
    - A version for the build itself (trigger a rebuild if the code has changed).
    
    HitchBuild will hash any variable it is passed to determine if it
    has changed, so, for example, you cannot directly use a list (although
    you can use tuple(a_list).
  given:
    files:
      sourcefile.txt: |
        the contents of this file, if changed, will trigger a rebuild.
    setup: |
      from path import Path
      import hitchbuild
      import hashlib

      class Thing(hitchbuild.HitchBuild):
          def __init__(self, src_dir):
              self._src_dir = Path(src_dir)
              self._src_contents = self.monitored_vars(
                  srcfile=self._src_dir.joinpath("sourcefile.txt").text(),
              )

          @property
          def srcfile(self):
              return self._src_dir/"sourcefile.txt"

          def fingerprint(self):
              return hashlib.sha1(self.thingpath.bytes()).hexdigest()

          @property
          def thingpath(self):
              return self.build_path/"thing.txt"

          def build(self):
              self.thingpath.write_text("build triggered\n", append=True)
              self.thingpath.write_text(
                  "vars changed: {0}\n".format(', '.join(self._src_contents.changes)),
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
        vars changed: srcfile
        build triggered
        vars changed: 

  - Write file:
      filename: sourcefile.txt
      content: the contents, now changed, should trigger a rebuild.

  - Run code: |
      build.ensure_built()

  - File contents will be:
      filename: thing.txt
      text: |-
        build triggered
        vars changed: srcfile
        build triggered
        vars changed: 
        build triggered
        vars changed: srcfile
