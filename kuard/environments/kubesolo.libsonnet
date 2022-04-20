local base = import './base.libsonnet';

base {
  kuard+: {
    ingressHostname: 'kubesolo-kuard.rogii.net',
  },
}
