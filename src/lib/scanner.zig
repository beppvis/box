const std = @import("std");
const token = @import("token.zig");
const Token = token.Token; 
const box = @import("box.zig");
const BoxError = box.BoxError;
const TokenType = token.TokenType;

pub const Scanner = struct {
    source: []const u8,
    tokens: std.ArrayList(token.Token),
    allocator: std.mem.Allocator,
    start: u8,
    current: u8,
    line: u8,
    const Self = @This();
    pub fn init(allocator: std.mem.Allocator, source: []const u8) !Self {
        return .{
            .source = source,
            .tokens = try std.ArrayList(token.Token).initCapacity(allocator, 2),
            .allocator = allocator,
            .start = 0,
            .current = 0,
            .line = 1,
        };
    }
    pub fn scanTokens(self: *Self) !void {
        while (!isAtEnd(self)) {
            self.start = self.current;
            try self.scanToken();
        }
        try self.addToken(TokenType.EOF);
    }
    pub fn isAtEnd(self: *Self) bool {
        return (self.current >= self.source.len);
    }
    pub fn addToken(self: *Self, tokenType: token.TokenType) !void {
        try self.addTokenObj(tokenType, null);
    }
    pub fn addTokenObj(self: *Self, tt: token.TokenType, literal: ?token.Literal) !void {
        try self.tokens.append(self.allocator, Token.init(tt, literal, self.source[self.start..self.current], self.line));
    }
    pub fn scanToken(self: *Self) !void {
        const c = self.advance();
        switch (c) {
            '(' => {
                try self.addToken(token.TokenType.LEFT_PAREN);
            },
            ')' => {
                try self.addToken(TokenType.RIGHT_PAREN);
            },
            '{' => {
                try self.addToken(TokenType.LEFT_BRACE);
            },
            '}' => {
                try self.addToken(TokenType.RIGHT_BRACE);
            },
            ',' => {
                try self.addToken(TokenType.COMMA);
            },
            '.' => {
                try self.addToken(TokenType.DOT);
            },
            '-' => {
                try self.addToken(TokenType.MINUS);
            },
            '+' => {
                try self.addToken(TokenType.PLUS);
            },
            ';' => {
                try self.addToken(TokenType.SEMICOLON);
            },
            '/' => {
                if (self.match('/')) {
                    while (self.peek() != '\n' and !self.isAtEnd()) _ = self.advance();
                } else {
                    try self.addToken(TokenType.SLASH);
                }
            },
            '*' => {
                try self.addToken(TokenType.STAR);
            },
            '!' => {
                try self.addToken(if (self.match('=')) TokenType.BANG_EQUAL else TokenType.BANG);
            },
            '=' => {
                try self.addToken(if (self.match('=')) TokenType.EQUAL_EQUAL else TokenType.EQUAL);
            },
            '>' => {
                try self.addToken(if (self.match('=')) TokenType.GREATER_EQUAL else TokenType.GREATER);
            },
            '<' => {
                try self.addToken(if (self.match('=')) TokenType.LESS_EQUAL else TokenType.LESS);
            },
            ' ', '\r', '\t', '\x00' => {},
            '\n' => {
                self.line += 1;
            },
            '"' => {
                try self.addTokenObj(TokenType.STRING,token.Literal{.string = try self.string()});
            },
            else => {
                return BoxError.InvalidToken;
            },
        }
    }
    pub fn string(self: *Self) ![]const u8 {
        while (self.peek() != '"' and !self.isAtEnd()) {
            if (self.peek() == '\n')
                self.line += 1;
            _ = self.advance();
        }
        if (self.peek() != '"') {
            return BoxError.StringNotTerminated;
        }
        _ = self.advance();
        return self.source[self.start + 1 .. self.current - 1];
    }
    pub fn peek(self: *Self) u8 {
        if (self.isAtEnd()) return '\x00'; // null character
        return self.source[self.current];
    }
    pub fn match(self: *Self, expected: u8) bool {
        if (self.isAtEnd()) return false;
        if (self.source[self.current] != expected) return false;
        self.current += 1;
        return true;
    }
    pub fn advance(self: *Self) u8 {
        const c = self.source[self.current];
        self.current += 1;
        return c;
    }
    pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
        self.tokens.deinit(allocator);
    }
};
