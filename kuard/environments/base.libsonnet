// this file has the baseline default parameters
{
  kuard: {
    confData: {
      'default.conf': |||
        server {
            listen       8000;
            server_name  test;
            location / {
                root   /var/www/html/webadmin;
                try_files $uri $uri/ /index.html;
            }
            location /static {
                alias /var/www/html/static;
            }
        }
      |||,
      'alert.conf': std.manifestYamlDoc({
        name: 'BlaBlaBla',
        type: 'any',
        realert: {
          minutes: 0,
        },
        index: 'cloudtrail-*',
        buffer_time: {
          minutes: 30,
        },
        filter: [
          {
            query: {
              query_string: {
                query: 'errorCode: "*UnauthorizedOperation" OR errorCode: "AccessDenied*"',
              },
            },
          },
        ],
        alert: [
          'opsgenie',
        ],
        opsgenie_tags: [
          'AWS',
          'Cloudtrail',
        ],
        opsgenie_priority: 'P5',
        num_events: 1,
      },),
    },
  },
}
