// this file returns the params for the current qbec environment

local env = std.extVar('qbec.io/env');
local p = import 'glob-import:environments/*.libsonnet';
local envName(f) = std.split(std.split(f, '.')[0], '/')[1];


local paramsMap = { _: import './environments/base.libsonnet' } +
                  { [envName(x)]: p[x] for x in std.objectFields(p) };

if std.objectHas(paramsMap, env)
then paramsMap[env]
else paramsMap.default
