#!/bin/sh

printf 'print_usage () {\n\tprintf "Usage: $0 <arguments>\\n">&2;\n\tprintf "\\n">&2;\n}\n\n';

printf 'print_usage_then_exit () {\n\tprint_usage;\n\texit 2;\n}\n\n';

printf 'if [ "$1" = "-h" ]; then print_usage_then_exit; fi\n\n';

printf 'describe_script () {\n\tprintf "$0: a script to...">&2;\n\tprintf "\\n">&2;\n}\n\n'

printf 'describe_script_then_exit () {\n\tdescribe_script;\n\texit 2;\n}\n\n'

printf 'if [ "$1" = "-e" ]; then describe_script_then_exit; fi\n\n';

printf 'if [ "$1" = "-eh" ]; then describe_script; print_usage; exit 2; fi\n\n';
