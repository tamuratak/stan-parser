import * as spSimple from './stan_parser_simple'
import * as spTrace from './stan_parser_trace'
import {ParserOptions as ParserOptionsBase} from '../pegjs/pegjs_types'

export {isSyntaxError} from '../pegjs/pegjs_types'
export type {Location, SyntaxError} from '../pegjs/pegjs_types'

/**
 * Stan parser options.
 */
export interface ParserOptions extends ParserOptionsBase {
    /**
     * Specifies a rule with which the parser begins. If `'Root'` is set, the whole document is parsed.
     * If `'Preamble'` is set, only the preamble is parsed.
     *
     * @default 'Root'
     */
    startRule?: 'Root';
    /**
     * All the comments in the LaTeX document will be extracted into a returned AST also.
     *
     * @default false
     */
    enableComment?: boolean;
}

/**
 * Parses a Stan program and returns a Stan AST.
 * @param stanString Stan program to be parsed.
 * @param optArg Options.
 *
 */
export function parse(
    texString: string,
    optArg?: ParserOptions
): unknown {
    const option = optArg ? Object.assign({}, optArg) : undefined
    if (option && option.tracer) {
        return spTrace.parse(texString, option)
    } else {
        return spSimple.parse(texString, option)
    }
}
