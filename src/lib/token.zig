const std = @import("std");
pub const TokenType = enum {
    // one character
    LEFT_PAREN,
    RIGHT_PAREN,
    LEFT_BRACE,
    RIGHT_BRACE,
    COMMA,
    DOT,
    MINUS,
    PLUS,
    SEMICOLON,
    SLASH,
    STAR,
    // One or two character tokens.
    BANG,
    BANG_EQUAL,
    EQUAL,
    EQUAL_EQUAL,
    GREATER,
    GREATER_EQUAL,
    LESS,
    LESS_EQUAL,

    // Literals.
    IDENTIFIER,
    STRING,
    NUMBER,

    // Keywords.
    AND,
    CLASS,
    ELSE,
    FALSE,
    FUN,
    FOR,
    IF,
    NIL,
    OR,
    PRINT,
    RETURN,
    SUPER,
    THIS,
    TRUE,
    VAR,
    WHILE,

    EOF,
};
pub const Numeric = union {
    float:f32,
    int: i32,
};
pub const Literal = union { numeric: Numeric, string: []const u8 };

pub const Token = struct {
    tokenType: TokenType,
    literal: ?Literal,
    lexeme: []const u8,
    line: u8,
    const Self = @This();
    pub fn init(tokenType: TokenType, literal: ?Literal, lexeme: []const u8, line: u8) Self {
        return .{
            .tokenType = tokenType,
            .literal = literal,
            .lexeme = lexeme,
            .line = line
        };
    }
};
