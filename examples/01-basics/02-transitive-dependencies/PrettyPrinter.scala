package example

import example.services.Formatter

@main
def run: Unit =
    println(Formatter.formatMessage("multi target graph"))
