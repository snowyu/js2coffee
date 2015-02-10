{ getPrecedence } = require('../helpers')
TransformerBase = require('./base')

###
# Fixes operator precedences
###

module.exports = class extends TransformerBase

  onEnter: (node, parent) ->
    return unless parent

    # No need to parenthesize arguments in `a(...)` and `a[...]`
    type = parent.type
    return if type is 'CallExpression' and parent.arguments.indexOf(node) > -1
    return if type is 'NewExpression' and parent.arguments.indexOf(node) > -1
    return if type is 'MemberExpression' and parent.property is node

    # Ensure that we actually care about the precedence of this node
    prec = getPrecedence(node)
    return if prec is -1

    # Ensure that the precedence calls for it (eg, + inside a /).
    # Make special care for intransitive operations (`a-(b-c)` vs `(a-b)-c`).
    if isIntransitive(parent) and isIntransitive(node) and parent.right is node
      return unless prec <= getPrecedence(parent)
    else
      return unless prec < getPrecedence(parent)

    node._parenthesized = true
    return

isIntransitive = (node) ->
  op = node.operator
  node.type is 'BinaryExpression' and (op is '-' or op is '/')

