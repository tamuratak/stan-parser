import {ParserOptions, SyntaxErrorBase} from '../pegjs/pegjs_types'

export declare class SyntaxError extends SyntaxErrorBase {}

export declare function parse( texString: string, option?: ParserOptions ): unknown
