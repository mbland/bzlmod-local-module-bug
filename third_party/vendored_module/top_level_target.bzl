"""Demo module"""

def _foo_library_impl():
    pass

foo_library = rule(implementation = _foo_library_impl)
