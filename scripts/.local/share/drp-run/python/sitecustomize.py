"""drp-run's import hook: python under drp-run gets its DRP credentials from
the environment instead of the services' hard-coded auth modules.

pig_patrol's scripts do `from auth.auth import get_auth`, and the repo's own
auth/ wins over anything on PYTHONPATH because the script's folder is
sys.path[0]. So rather than shadow the package, this finder lets the real
auth.auth (or auth.auth.auth) load and then replaces its get_auth with one
returning DRP_USER/DRP_PASSWORD, as the same type the original returned
(requests' HTTPBasicAuth where the module imports it, else a tuple). It
refuses any env but drp-run's DRP_ENV, so TEST credentials can't reach PROD.

Another sitecustomize further down sys.path still runs.
"""

import importlib.abc
import importlib.machinery
import importlib.util
import os
import sys

_TARGETS = {"auth.auth", "auth.auth.auth"}
_HERE = os.path.dirname(os.path.abspath(__file__))


def _get_auth_from_env(module):
    basic = getattr(module, "HTTPBasicAuth", None)

    def get_auth(env=None, *args, **kwargs):
        want = os.environ.get("DRP_ENV", "")
        if env is not None and str(env).upper() != want:
            raise RuntimeError(f"drp-run: credentials are for {want}, the script asked for {env}")
        user, password = os.environ["DRP_USER"], os.environ["DRP_PASSWORD"]
        return basic(user, password) if basic else (user, password)

    return get_auth


class _Patching(importlib.abc.Loader):
    def __init__(self, loader):
        self._loader = loader

    def create_module(self, spec):
        return self._loader.create_module(spec)

    def exec_module(self, module):
        self._loader.exec_module(module)
        if hasattr(module, "get_auth"):
            module.get_auth = _get_auth_from_env(module)


class _Finder(importlib.abc.MetaPathFinder):
    def find_spec(self, fullname, path, target=None):
        if fullname not in _TARGETS or "DRP_USER" not in os.environ:
            return None
        spec = importlib.machinery.PathFinder.find_spec(fullname, path)
        if spec is not None and spec.loader is not None:
            spec.loader = _Patching(spec.loader)
        return spec


sys.meta_path.insert(0, _Finder())

# Chain to the sitecustomize this one shadows, if any.
_rest = [p for p in sys.path if os.path.abspath(p or ".") != _HERE]
_spec = importlib.machinery.PathFinder.find_spec("sitecustomize", _rest)
if _spec is not None and _spec.loader is not None:
    _mod = importlib.util.module_from_spec(_spec)
    _spec.loader.exec_module(_mod)
