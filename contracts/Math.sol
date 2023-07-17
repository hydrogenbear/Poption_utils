// SPDX-License-Identifier: BUSL-1.1
/*
 * Math 64x64 Smart Contract Library.
 * Copyright ©2022 by Poption.org.
 * Author: Hydrogenbear <hydrogenbear@poption.org>
 */

pragma solidity ^0.8.4;

library Math64x64 {
    uint256 internal constant ONE = 0x10000000000000000;
    uint256 internal constant ONEONE = 0x100000000000000000000000000000000;
    uint256 internal constant MAX128 = 0xffffffffffffffffffffffffffffffff;

    function mul(int256 x, int256 y) internal pure returns (int128 r) {
        assembly {
            r := sar(64, mul(x, y))
            if and(
                gt(r, 0x7fffffffffffffffffffffffffffffff),
                lt(
                    r,
                    0xffffffffffffffffffffffffffffffff80000000000000000000000000000000
                )
            ) {
                revert(0, 0)
            }
        }
    }

    function mul(uint128 x, uint128 y) internal pure returns (uint128 r) {
        assembly {
            r := shr(64, mul(x, y))
            if gt(r, MAX128) {
                revert(0, 0)
            }
        }
    }

    function div(uint128 x, uint128 y) internal pure returns (uint128 r) {
        assembly {
            r := div(shl(64, x), y)
            if gt(r, MAX128) {
                revert(0, 0)
            }
        }
    }

    function div(int128 x, int128 y) internal pure returns (int128 r) {
        assembly {
            if iszero(y) {
                revert(0, 0)
            }
            r := sdiv(shl(64, x), y)
            if and(
                gt(r, 0x7fffffffffffffffffffffffffffffff),
                lt(
                    r,
                    0xffffffffffffffffffffffffffffffff80000000000000000000000000000000
                )
            ) {
                revert(0, 0)
            }
        }
    }

    function msb(int128 x) internal pure returns (int128 r) {
        require(x >= 0, "No Neg");
        unchecked {
            return msb(uint128(x));
        }
    }

    function msb(uint128 x) internal pure returns (int128 r) {
        assembly {
            let j := mul(gt(x, 0xffffffffffffffff), 0x40)
            x := shr(j, x)
            r := add(j, r)

            j := mul(gt(x, 0xffffffff), 0x20)
            x := shr(j, x)
            r := add(j, r)

            j := mul(gt(x, 0xffff), 0x10)
            x := shr(j, x)
            r := add(j, r)

            j := mul(gt(x, 0xff), 0x8)
            x := shr(j, x)
            r := add(j, r)

            j := mul(gt(x, 0xf), 0x4)
            x := shr(j, x)
            r := add(j, r)

            j := mul(gt(x, 0x3), 0x2)
            x := shr(j, x)
            r := add(j, r)

            j := mul(gt(x, 0x1), 0x1)
            x := shr(j, x)
            r := add(j, r)
        }
    }

    function ln(uint128 rx) internal pure returns (int128) {
        require(rx > 0, "Be Pos");
        unchecked {
            int256 r = msb(rx);

            assembly {
                let x := shl(sub(127, r), rx)
                r := sar(
                    50,
                    mul(
                        sub(r, 63),
                        265561240842969827543796575331103159507101128947518051
                    )
                )
                if lt(x, 0xb504f333f9de6484597d89b3754abe9f) {
                    x := shr(128, mul(x, 0x16a09e667f3bcc908b2fb1366ea957d3e))
                    r := sub(r, 0x58b90bfbe8e7bcd5e4f1d9cc01f97b58)
                }

                if lt(x, 0xd744fccad69d6af439a68bb9902d3fde) {
                    x := shr(128, mul(x, 0x1306fe0a31b7152de8d5a46305c85eded))
                    r := sub(r, 0x2c5c85fdf473de6af278ece600fcbdac)
                }

                if lt(x, 0xeac0c6e7dd24392ed02d75b3706e54fb) {
                    x := shr(128, mul(x, 0x1172b83c7d517adcdf7c8c50eb14a7920))
                    r := sub(r, 0x162e42fefa39ef35793c7673007e5ed6)
                }

                if lt(x, 0xf5257d152486cc2c7b9d0c7aed980fc4) {
                    x := shr(128, mul(x, 0x10b5586cf9890f6298b92b71842a98364))
                    r := sub(r, 0xb17217f7d1cf79abc9e3b39803f2f6b)
                }

                if lt(x, 0xfa83b2db722a033a7c25bb14315d7fcd) {
                    x := shr(128, mul(x, 0x1059b0d31585743ae7c548eb68ca417ff))
                    r := sub(r, 0x58b90bfbe8e7bcd5e4f1d9cc01f97b6)
                }

                if lt(x, 0xfd3e0c0cf486c174853f3a5931e0ee03) {
                    x := shr(128, mul(x, 0x102c9a3e778060ee6f7caca4f7a29bde9))
                    r := sub(r, 0x2c5c85fdf473de6af278ece600fcbdb)
                }

                let m := div(
                    shl(128, sub(0x100000000000000000000000000000000, x)),
                    add(0x100000000000000000000000000000000, x)
                )
                let im := m
                let rr := m
                m := shr(128, mul(m, m))
                for {
                    let i := 3
                } gt(im, 0x10000000000000000) {
                    i := add(i, 6)
                } {
                    im := shr(128, mul(im, m))
                    rr := add(rr, div(im, i))
                    im := shr(128, mul(im, m))
                    rr := add(rr, div(im, add(i, 2)))
                    im := shr(128, mul(im, m))
                    rr := add(rr, div(im, add(i, 4)))
                }
                r := sar(64, sub(r, shl(1, rr)))
            }
            return int128(r);
        }
    }

    function sqrt(uint128 x) internal pure returns (uint128 r) {
        unchecked {
            int128 msbx = msb(x);
            assembly {
                let rx := shl(64, x)
                r := shr(add(32, sar(1, msbx)), rx)
                r := shr(1, add(div(rx, r), r))
                r := shr(1, add(div(rx, r), r))
                r := shr(1, add(div(rx, r), r))
                r := shr(1, add(div(rx, r), r))
                r := shr(1, add(div(rx, r), r))
                r := shr(1, add(div(rx, r), r))
            }
        }
    }

    function normCdf(int128 x) internal pure returns (uint128 r) {
        assembly {
            let sgn := 1
            if gt(
                x,
                0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
            ) {
                x := sub(0, x)
                sgn := 0
            }
            switch gt(x, 0x927c1552af58a0000)
            case 1 {
                r := 0
            }
            default {
                r := sar(64, mul(x, 0x5a4fb39ac251))
                r := sar(64, mul(x, add(r, 0x3343fae611b8a)))
                r := sar(64, mul(x, add(r, 0x27d981c9c0bf2)))
                r := sar(64, mul(x, add(r, 0xd6cd71dee78ea0)))
                r := sar(64, mul(x, add(r, 0x5697f3a04cf1580)))
                r := sar(64, mul(x, add(r, 0xcc41b405c539100)))
                r := add(r, 0x10000000000000000)
                r := sar(64, mul(r, r))
                r := sar(64, mul(r, r))
                r := sar(64, mul(r, r))
                r := sar(64, mul(r, r))
                r := div(0x80000000000000000000000000000000, r)
            }
            if sgn {
                r := sub(0x10000000000000000, r)
            }
        }
    }

    function cauchyCdf(int128 x) internal pure returns (uint128 r) {
        assembly {
            r := x
            let sgn := 1
            if gt(
                r,
                0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
            ) {
                r := sub(0, r)
                sgn := 0
            }
            let inv := 1
            if gt(r, 0x10000000000000000) {
                r := div(0x100000000000000000000000000000000, r)
                inv := 0
            }
            let x2_ := sar(64, mul(r, r))
            let y := sub(sar(64, mul(2124161823823364, x2_)), 16640283787842336)
            y := add(sar(64, mul(y, x2_)), 61222568753354112)
            y := sub(sar(64, mul(y, x2_)), 143277719382150352)
            y := add(sar(64, mul(y, x2_)), 246608687101375616)
            y := sub(sar(64, mul(y, x2_)), 346968386593137216)
            y := add(sar(64, mul(y, x2_)), 437013696018853440)
            y := sub(sar(64, mul(y, x2_)), 530379345809171520)
            y := add(sar(64, mul(y, x2_)), 651880698001138560)
            y := sub(sar(64, mul(y, x2_)), 838771940666329344)
            y := add(sar(64, mul(y, x2_)), 1174353130486501120)
            y := sub(sar(64, mul(y, x2_)), 1957260253410140928)
            y := add(sar(64, mul(y, x2_)), 5871781005908458496)
            r := sar(64, mul(y, r))

            if xor(sgn, inv) {
                r := add(sub(0, r), 0x8000000000000000)
            }
            if sgn {
                r := add(r, 0x8000000000000000)
            }
        }
    }

    function exp(uint128 x) internal pure returns (uint128 r) {
        require(x < 0x2bab13e5fca20ef146, "Overflow");
        if (x == 0) {
            return 0x10000000000000000;
        }
        assembly {
            let k := add(
                div(shl(64, x), 0xb17217f7d1cf79ab),
                0x7fffffffffffffff
            )
            k := sar(64, k)
            let rr := sub(x, mul(k, 0xb17217f7d1cf79ab))

            r := 0x10000000000000000
            for {
                let i := 0x12
            } gt(i, 0) {
                i := sub(i, 1)
            } {
                r := add(sar(64, mul(r, sdiv(rr, i))), 0x10000000000000000)
            }
            r := shl(k, r)
        }
    }
}
