package example.services

import example.core.CharOperations

object Formatter:
    def formatMessage(msg: String): String = 
        s"FORMATED: ${CharOperations.toUpperCase(msg)}"
