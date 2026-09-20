#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
상태 천이도 생성기 (Boolean equations -> state table + transition graph)

플립플롭 입력식과 출력식을 쓰면
  · 상태표(현재상태 / 입력 / FF입력 / 다음상태 / 출력)
  · 상태 천이도(Moore / Mealy 자동 판별)
를 만들어 줍니다.

식 문법
  AND  : 붙여쓰기(A B), *, &, .
  OR   : +, |
  XOR  : ^
  NOT  : A'  또는  ~A, !A
  괄호 : ( )
  상수 : 0, 1

플립플롭
  D 형 : DA = ...        (또는 A* = ... , A+ = ...)
  T 형 : TA = ...
  JK 형: JA = ... / KA = ...
그 밖의 좌변은 모두 출력식으로 봅니다.

표준 라이브러리(tkinter)만으로 실행됩니다. Pillow가 있으면 PNG로 저장됩니다.
"""

import itertools
import math
import re
import sys
import tkinter as tk
from tkinter import ttk, filedialog, messagebox

try:
    from PIL import Image, ImageDraw, ImageFont
    HAS_PIL = True
except ImportError:
    HAS_PIL = False

# ── 색 ───────────────────────────────────────────────────────────────
PAPER = "#FFFFFF"
INK = "#101922"
MUTED = "#67767F"
LINE = "#CCD7E0"
ACCENT = "#1750E8"
SOFT = "#EAF0FF"
GHOST = "#B6C2CC"
DANGER = "#AF3A1D"

if sys.platform == "darwin":
    MONO = "Menlo"
elif sys.platform.startswith("win"):
    MONO = "Consolas"
else:
    MONO = "DejaVu Sans Mono"

FONT_CANDIDATES = [
    "DejaVuSansMono.ttf", "consola.ttf", "Menlo.ttc", "cour.ttf",
    "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf",
    "C:/Windows/Fonts/consola.ttf", "/System/Library/Fonts/Menlo.ttc",
]

# PNG로 저장할 때 한글 캡션에 쓸 글꼴 (없으면 영문 캡션으로 바뀝니다)
CJK_CANDIDATES = [
    "C:/Windows/Fonts/malgun.ttf", "malgun.ttf",
    "/System/Library/Fonts/AppleSDGothicNeo.ttc", "AppleSDGothicNeo.ttc",
    "/usr/share/fonts/truetype/nanum/NanumGothic.ttf", "NanumGothic.ttf",
    "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc",
    "/usr/share/fonts/opentype/noto/NotoSansCJK-Medium.ttc",
    "/usr/share/fonts/truetype/noto/NotoSansCJK-Regular.ttc",
    "NotoSansCJK-Regular.ttc", "NotoSansKR-Regular.otf",
]

NODE_R = 27


# ── 불리언 식 파서 ───────────────────────────────────────────────────
class EqError(Exception):
    pass


TOKEN = re.compile(r"\s*([A-Za-z_][A-Za-z_0-9]*|[01]|[+|^*&.()'~!])")


def tokenize(src):
    out, i = [], 0
    while i < len(src):
        if src[i].isspace():
            i += 1
            continue
        m = TOKEN.match(src, i)
        if not m:
            raise EqError("알 수 없는 문자: %r" % src[i])
        out.append(m.group(1))
        i = m.end()
    return out


class Parser:
    """재귀 하강 파서 -> 튜플 트리

    known 에 선언된 변수 목록을 주면 AB' 처럼 붙여 쓴 이름을
    A·B' 로 쪼개 읽습니다.
    """

    def __init__(self, src, known=()):
        self.t = tokenize(src)
        self.i = 0
        self.known = list(known)

    def peek(self):
        return self.t[self.i] if self.i < len(self.t) else None

    def take(self):
        tok = self.peek()
        self.i += 1
        return tok

    def parse(self):
        if not self.t:
            raise EqError("식이 비어 있습니다")
        node = self.p_or()
        if self.peek() is not None:
            raise EqError("식을 끝까지 읽지 못했습니다: %r 부근" % self.peek())
        return node

    def p_or(self):
        n = self.p_xor()
        while self.peek() in ("+", "|"):
            self.take()
            n = ("or", n, self.p_xor())
        return n

    def p_xor(self):
        n = self.p_and()
        while self.peek() == "^":
            self.take()
            n = ("xor", n, self.p_and())
        return n

    def p_and(self):
        n = self.p_not()
        while True:
            p = self.peek()
            if p in ("*", "&", "."):
                self.take()
                n = ("and", n, self.p_not())
            elif p is not None and (p == "(" or p in ("~", "!") or
                                    re.match(r"^[A-Za-z_01]", p)):
                n = ("and", n, self.p_not())          # 붙여쓰기 AND
            else:
                return n

    def p_not(self):
        if self.peek() in ("~", "!"):
            self.take()
            return ("not", self.p_not())
        return self.p_post()

    def p_post(self):
        parts = self.p_atom()          # 항상 리스트로 받습니다
        while self.peek() == "'":
            self.take()
            parts[-1] = ("not", parts[-1])   # AB' 는 A·(B') 로 읽습니다
        n = parts[0]
        for p in parts[1:]:
            n = ("and", n, p)
        return n

    def _split(self, name):
        """AB'처럼 붙여 쓴 이름을 선언된 변수들로 쪼갭니다."""
        if not self.known:
            return [("var", name)]
        names = sorted(self.known, key=len, reverse=True)
        out, i = [], 0
        while i < len(name):
            for v in names:
                if name.startswith(v, i):
                    out.append(("var", v))
                    i += len(v)
                    break
            else:
                raise EqError("모르는 변수: %s  (선언된 변수: %s)"
                              % (name, ", ".join(self.known)))
        return out

    def p_atom(self):
        tok = self.take()
        if tok is None:
            raise EqError("식이 중간에 끊겼습니다")
        if tok == "(":
            n = self.p_or()
            if self.take() != ")":
                raise EqError("괄호가 닫히지 않았습니다")
            return [n]
        if tok in ("0", "1"):
            return [("const", int(tok))]
        if re.match(r"^[A-Za-z_]", tok):
            if not self.known or tok in self.known:
                return [("var", tok)]
            return self._split(tok)
        raise EqError("예상하지 못한 기호: %r" % tok)


def ev(node, env):
    k = node[0]
    if k == "const":
        return node[1]
    if k == "var":
        if node[1] not in env:
            raise EqError("모르는 변수: %s  (선언된 변수: %s)"
                          % (node[1], ", ".join(sorted(env))))
        return env[node[1]]
    if k == "not":
        return 1 - ev(node[1], env)
    a, b = ev(node[1], env), ev(node[2], env)
    return {"and": a & b, "or": a | b, "xor": a ^ b}[k]


def used_vars(node, acc=None):
    acc = set() if acc is None else acc
    if node[0] == "var":
        acc.add(node[1])
    elif node[0] in ("and", "or", "xor"):
        used_vars(node[1], acc)
        used_vars(node[2], acc)
    elif node[0] == "not":
        used_vars(node[1], acc)
    return acc


# ── FSM 모델 ─────────────────────────────────────────────────────────
class FSM:
    def __init__(self, state_vars, in_vars, eq_text, start=""):
        self.S = [s.strip() for s in re.split(r"[,\s]+", state_vars) if s.strip()]
        self.X = [s.strip() for s in re.split(r"[,\s]+", in_vars) if s.strip()]
        if not self.S:
            raise EqError("상태 변수를 한 개 이상 적어 주세요 (예: A, B)")
        if len(self.S) > 6:
            raise EqError("상태 변수는 6개까지 지원합니다 (지금 %d개)" % len(self.S))
        if len(set(self.S) | set(self.X)) != len(self.S) + len(self.X):
            raise EqError("상태 변수와 입력 변수에 같은 이름이 있습니다")

        self.ff = {}        # 상태변수 -> {'type':'D'|'T'|'JK', 'D'/'T'/'J'/'K': tree}
        self.out = []       # [(이름, tree)]
        self._parse(eq_text)

        for s in self.S:
            if s not in self.ff:
                raise EqError("%s 의 다음 상태 식이 없습니다 (예: D%s = ... )" % (s, s))
            f = self.ff[s]
            if f["type"] == "JK" and ("J" not in f or "K" not in f):
                raise EqError("%s 는 J 와 K 식이 모두 필요합니다" % s)

        self.n = len(self.S)
        self.m = len(self.X)
        self.states = [tuple(b) for b in itertools.product((0, 1), repeat=self.n)]
        self.ins = [tuple(b) for b in itertools.product((0, 1), repeat=self.m)] if self.m else [()]

        self.mealy = any(used_vars(t) & set(self.X) for _, t in self.out)
        self.rows = self._build()
        self.start = self._resolve_start(start)
        self.reach = self._reachable()

    def _parse(self, text):
        for ln in text.splitlines():
            ln = ln.split("#")[0].split("//")[0].strip()
            if not ln:
                continue
            if "=" not in ln:
                raise EqError("'=' 가 없는 줄: %s" % ln)
            lhs, rhs = ln.split("=", 1)
            lhs, rhs = lhs.strip(), rhs.strip()
            tree = Parser(rhs, self.S + self.X).parse()

            # A* = ... / A+ = ...  (D형으로 취급)
            if lhs[-1:] in ("*", "+") and lhs[:-1].strip() in self.S:
                self.ff[lhs[:-1].strip()] = {"type": "D", "D": tree}
                continue
            m = re.match(r"^([DTJK])_?(\w+)$", lhs)
            if m and m.group(2) in self.S:
                kind, sv = m.group(1), m.group(2)
                cur = self.ff.setdefault(sv, {"type": kind})
                cur["type"] = "JK" if kind in "JK" else kind
                cur[kind] = tree
                continue
            if lhs in self.S:      # A = ... 처럼 써도 D형으로
                self.ff[lhs] = {"type": "D", "D": tree}
                continue
            self.out.append((lhs, tree))

    def env(self, st, xi):
        e = dict(zip(self.S, st))
        e.update(zip(self.X, xi))
        return e

    def next_of(self, st, xi):
        e = self.env(st, xi)
        nxt, ffv = [], []
        for k, s in enumerate(self.S):
            f = self.ff[s]
            q = st[k]
            if f["type"] == "D":
                d = ev(f["D"], e)
                ffv.append(("D%s" % s, d))
                nxt.append(d)
            elif f["type"] == "T":
                t = ev(f["T"], e)
                ffv.append(("T%s" % s, t))
                nxt.append(q ^ t)
            else:
                j, kk = ev(f["J"], e), ev(f["K"], e)
                ffv.append(("J%s" % s, j))
                ffv.append(("K%s" % s, kk))
                nxt.append((j & (1 - q)) | ((1 - kk) & q))
        return tuple(nxt), ffv

    def _build(self):
        rows = []
        for st in self.states:
            for xi in self.ins:
                nxt, ffv = self.next_of(st, xi)
                e = self.env(st, xi)
                outs = [(nm, ev(t, e)) for nm, t in self.out]
                rows.append(dict(cur=st, x=xi, nxt=nxt, ff=ffv, out=outs))
        return rows

    def _resolve_start(self, s):
        s = (s or "").strip()
        if s and re.fullmatch(r"[01]{%d}" % self.n, s):
            return tuple(int(c) for c in s)
        return tuple([0] * self.n)

    def _reachable(self):
        seen, stack = {self.start}, [self.start]
        while stack:
            cur = stack.pop()
            for xi in self.ins:
                nx = self.next_of(cur, xi)[0]
                if nx not in seen:
                    seen.add(nx)
                    stack.append(nx)
        return seen

    # 표시용
    def sname(self, st):
        return "".join(str(b) for b in st)

    def out_str(self, outs):
        return "".join(str(v) for _, v in outs)

    def edges(self):
        """(from, to) -> 라벨 목록"""
        agg = {}
        for r in self.rows:
            key = (r["cur"], r["nxt"])
            xs = "".join(str(b) for b in r["x"]) if r["x"] else ""
            lab = "%s/%s" % (xs, self.out_str(r["out"])) if self.mealy else xs
            agg.setdefault(key, []).append(lab)
        return agg

    def node_label(self, st):
        if self.mealy or not self.out:
            return self.sname(st)
        e = self.env(st, self.ins[0])
        return "%s/%s" % (self.sname(st), "".join(str(ev(t, e)) for _, t in self.out))

    def table_text(self):
        ffn = [nm for nm, _ in self.rows[0]["ff"]]
        outn = [nm for nm, _ in self.out]
        head = (["현재 " + " ".join(self.S)] +
                (["입력 " + " ".join(self.X)] if self.X else []) +
                ([" ".join(ffn)] if ffn else []) +
                ["다음 " + " ".join(self.S)] +
                ([" ".join(outn)] if outn else []))
        body = []
        for r in self.rows:
            cells = [" ".join(str(b) for b in r["cur"])]
            if self.X:
                cells.append(" ".join(str(b) for b in r["x"]))
            if ffn:
                cells.append(" ".join(str(v) for _, v in r["ff"]))
            cells.append(" ".join(str(b) for b in r["nxt"]))
            if outn:
                cells.append(" ".join(str(v) for _, v in r["out"]))
            body.append(cells)
        w = [max(len(head[i]), max(len(b[i]) for b in body)) + 2 for i in range(len(head))]
        sep = "─" * (sum(w) + len(w) - 1)
        lines = ["│".join(h.center(w[i]) for i, h in enumerate(head)), sep]
        group = len(self.ins) > 1          # 입력이 있을 때만 상태별로 끊습니다
        prev = None
        for r, cells in zip(self.rows, body):
            if group and prev is not None and r["cur"] != prev:
                lines.append(sep)
            prev = r["cur"]
            lines.append("│".join(c.center(w[i]) for i, c in enumerate(cells)))
        kind = "Mealy (출력이 입력에 따라 변함)" if self.mealy else "Moore (출력이 상태에만 의존)"
        unre = [self.sname(s) for s in self.states if s not in self.reach]
        tail = ["", "형식: " + kind,
                "초기 상태: " + self.sname(self.start),
                "도달 불가 상태: " + (", ".join(unre) if unre else "없음")]
        return "\n".join(lines + tail)


# ── 렌더링 백엔드 ────────────────────────────────────────────────────
class TkBE:
    def __init__(self, c):
        self.c = c

    def polyline(self, pts, color=INK, width=2, dash=None):
        flat = [v for p in pts for v in p]
        self.c.create_line(*flat, fill=color, width=width, dash=dash)

    def polygon(self, pts, fill=INK, outline=""):
        flat = [v for p in pts for v in p]
        self.c.create_polygon(*flat, fill=fill, outline=outline)

    def ellipse(self, x1, y1, x2, y2, fill="", outline=INK, width=2, dash=None):
        self.c.create_oval(x1, y1, x2, y2, fill=fill, outline=outline,
                           width=width, dash=dash)

    def rect(self, x1, y1, x2, y2, fill="", outline=""):
        self.c.create_rectangle(x1, y1, x2, y2, fill=fill, outline=outline)

    def text(self, x, y, s, color=INK, size=12, bold=False, anchor="c"):
        a = {"c": "center", "w": "w", "e": "e"}[anchor]
        self.c.create_text(x, y, text=s, fill=color, anchor=a,
                           font=(MONO, size, "bold" if bold else "normal"))


def _has_cjk_font():
    if not HAS_PIL:
        return False
    for c in CJK_CANDIDATES:
        try:
            ImageFont.truetype(c, 12)
            return True
        except Exception:
            continue
    return False


class PilBE:
    def __init__(self, im, k=2):
        self.d = ImageDraw.Draw(im)
        self.k = k
        self._f = {}

    def _font(self, size, bold, cjk=False):
        key = (size, bold, cjk)
        if key not in self._f:
            f = None
            for c in (CJK_CANDIDATES if cjk else []) + FONT_CANDIDATES:
                try:
                    f = ImageFont.truetype(c, int(size * self.k))
                    break
                except Exception:
                    continue
            self._f[key] = f or ImageFont.load_default()
        return self._f[key]

    def polyline(self, pts, color=INK, width=2, dash=None):
        k = self.k
        self.d.line([(x * k, y * k) for x, y in pts], fill=color,
                    width=max(1, int(width * k)), joint="curve")

    def polygon(self, pts, fill=INK, outline=""):
        k = self.k
        self.d.polygon([(x * k, y * k) for x, y in pts], fill=fill or None,
                       outline=outline or None)

    def ellipse(self, x1, y1, x2, y2, fill="", outline=INK, width=2, dash=None):
        k = self.k
        self.d.ellipse([x1 * k, y1 * k, x2 * k, y2 * k], fill=fill or None,
                       outline=outline or None, width=max(1, int(width * k)))

    def rect(self, x1, y1, x2, y2, fill="", outline=""):
        k = self.k
        self.d.rectangle([x1 * k, y1 * k, x2 * k, y2 * k], fill=fill or None,
                         outline=outline or None)

    def text(self, x, y, s, color=INK, size=12, bold=False, anchor="c"):
        k = self.k
        a = {"c": "mm", "w": "lm", "e": "rm"}[anchor]
        cjk = any(ord(ch) > 0x2000 for ch in s)
        self.d.text((x * k, y * k), s, fill=color,
                    font=self._font(size, bold, cjk), anchor=a)


# ── 그래프 그리기 ────────────────────────────────────────────────────
def qbez(p0, p1, p2, n=26):
    return [((1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t * t * p2[0],
             (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t * t * p2[1])
            for t in (i / n for i in range(n + 1))]


def cbez(p0, p1, p2, p3, n=30):
    pts = []
    for i in range(n + 1):
        t = i / n
        u = 1 - t
        pts.append((u ** 3 * p0[0] + 3 * u * u * t * p1[0] + 3 * u * t * t * p2[0] + t ** 3 * p3[0],
                    u ** 3 * p0[1] + 3 * u * u * t * p1[1] + 3 * u * t * t * p2[1] + t ** 3 * p3[1]))
    return pts


def arrow_head(pts, size=9):
    (x1, y1), (x2, y2) = pts[-2], pts[-1]
    a = math.atan2(y2 - y1, x2 - x1)
    return [(x2, y2),
            (x2 - size * math.cos(a - 0.42), y2 - size * math.sin(a - 0.42)),
            (x2 - size * math.cos(a + 0.42), y2 - size * math.sin(a + 0.42))]


def _radius(n):
    return max(120, n * 2.9 * NODE_R / (2 * math.pi))


def graph_size(fsm):
    s = int(2 * (_radius(len(fsm.states)) + NODE_R + 70))
    return max(640, s), max(520, s)


def layout(fsm, W, H):
    n = len(fsm.states)
    cx, cy = W / 2, H / 2
    if n == 1:
        return {fsm.states[0]: (cx, cy)}
    R = min(_radius(n), min(W, H) / 2 - NODE_R - 62)
    pos = {}
    for i, st in enumerate(fsm.states):
        a = -math.pi / 2 + 2 * math.pi * i / n
        pos[st] = (cx + R * math.cos(a), cy + R * math.sin(a))
    return pos


def caption(fsm, ascii_only=False):
    if ascii_only:
        return ("Mealy - edge label = input/output" if fsm.mealy
                else "Moore - node label = state/output")
    return ("Mealy · 화살표 = 입력/출력" if fsm.mealy
            else "Moore · 원 안 = 상태/출력")


def draw_graph(be, fsm, W, H, title="", ascii_caption=False):
    be.rect(0, 0, W, H, fill=PAPER)
    pos = layout(fsm, W, H)
    if title:
        be.text(W / 2, 24, title, color=INK, size=13, bold=True)
    be.text(W / 2, H - 18, caption(fsm, ascii_caption), color=MUTED, size=10)

    cx, cy = W / 2, H / 2
    for (a, b), labs in fsm.edges().items():
        lab = ", ".join(sorted(set(labs)))
        p, q = pos[a], pos[b]
        if a == b:                                   # 자기 자신으로
            ang = math.atan2(p[1] - cy, p[0] - cx) if len(pos) > 1 else -math.pi / 2
            s1 = (p[0] + NODE_R * math.cos(ang - 0.5), p[1] + NODE_R * math.sin(ang - 0.5))
            s2 = (p[0] + NODE_R * math.cos(ang + 0.5), p[1] + NODE_R * math.sin(ang + 0.5))
            c1 = (p[0] + 2.9 * NODE_R * math.cos(ang - 0.55), p[1] + 2.9 * NODE_R * math.sin(ang - 0.55))
            c2 = (p[0] + 2.9 * NODE_R * math.cos(ang + 0.55), p[1] + 2.9 * NODE_R * math.sin(ang + 0.55))
            pts = cbez(s1, c1, c2, s2)
            lx = p[0] + 2.6 * NODE_R * math.cos(ang)
            ly = p[1] + 2.6 * NODE_R * math.sin(ang)
        else:
            dx, dy = q[0] - p[0], q[1] - p[1]
            d = math.hypot(dx, dy) or 1
            ux, uy = dx / d, dy / d
            off = 0.18 * d
            mid = ((p[0] + q[0]) / 2 - uy * off, (p[1] + q[1]) / 2 + ux * off)
            dp = math.hypot(mid[0] - p[0], mid[1] - p[1]) or 1
            s = (p[0] + NODE_R * (mid[0] - p[0]) / dp, p[1] + NODE_R * (mid[1] - p[1]) / dp)
            dq = math.hypot(mid[0] - q[0], mid[1] - q[1]) or 1
            e = (q[0] + NODE_R * (mid[0] - q[0]) / dq, q[1] + NODE_R * (mid[1] - q[1]) / dq)
            pts = qbez(s, mid, e)
            lx, ly = (s[0] + 2 * mid[0] + e[0]) / 4, (s[1] + 2 * mid[1] + e[1]) / 4

        dim = a not in fsm.reach
        be.polyline(pts, color=GHOST if dim else INK, width=1.6)
        be.polygon(arrow_head(pts), fill=GHOST if dim else INK)
        if lab:                       # 입력이 없으면 라벨 자리를 비웁니다
            w = 6.8 * len(lab) + 8
            be.rect(lx - w / 2, ly - 9, lx + w / 2, ly + 9, fill=PAPER)
            be.text(lx, ly, lab, color=MUTED if dim else ACCENT, size=11, bold=True)

    for st, (x, y) in pos.items():
        on = st in fsm.reach
        if st == fsm.start:
            be.polyline([(x - NODE_R - 34, y), (x - NODE_R - 6, y)], color=ACCENT, width=2)
            be.polygon(arrow_head([(x - NODE_R - 34, y), (x - NODE_R - 5, y)]), fill=ACCENT)
        be.ellipse(x - NODE_R, y - NODE_R, x + NODE_R, y + NODE_R,
                   fill=SOFT if on else PAPER, outline=INK if on else GHOST,
                   width=2, dash=None if on else (3, 3))
        be.text(x, y, fsm.node_label(st), color=INK if on else GHOST, size=12, bold=True)


def render_png(fsm, path, k=2):
    W, H = graph_size(fsm)
    im = Image.new("RGB", (W * k, H * k), PAPER)
    draw_graph(PilBE(im, k), fsm, W, H, ascii_caption=not _has_cjk_font())
    im.save(path)
    return path


# ── 앱 ───────────────────────────────────────────────────────────────
DEFAULT_EQ = "DA = A x + B x\nDB = A' x\ny  = (A + B) x'"

EXAMPLES = [
    ("D형 시퀀스 검출기 (Mealy)", "A, B", "x", "00",
     "DA = A x + B x\nDB = A' x\ny  = (A + B) x'"),
    ("JK형 카운터", "A, B", "x", "00",
     "JA = B x\nKA = B x'\nJB = x'\nKB = (A ^ x)'"),
    ("T형 3비트 업카운터 (입력 없음)", "Q2, Q1, Q0", "", "000",
     "TQ0 = 1\nTQ1 = Q0\nTQ2 = Q0 Q1"),
    ("Moore형 (출력이 상태만 따름)", "A, B", "x", "00",
     "DA = A ^ B\nDB = x' B + x A'\nz  = A B'"),
]


class App(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("상태 천이도 생성기")
        self.geometry("1180x780")
        self.fsm = None

        left = ttk.Frame(self, padding=10)
        left.pack(side="left", fill="y")

        ttk.Label(left, text="상태 변수 (플립플롭)").pack(anchor="w")
        self.v_state = tk.StringVar(value="A, B")
        ttk.Entry(left, textvariable=self.v_state, width=32).pack(fill="x", pady=(2, 8))

        ttk.Label(left, text="입력 변수 (없으면 비움)").pack(anchor="w")
        self.v_in = tk.StringVar(value="x")
        ttk.Entry(left, textvariable=self.v_in, width=32).pack(fill="x", pady=(2, 8))

        ttk.Label(left, text="초기 상태 (예: 00)").pack(anchor="w")
        self.v_start = tk.StringVar(value="00")
        ttk.Entry(left, textvariable=self.v_start, width=10).pack(anchor="w", pady=(2, 8))

        ttk.Label(left, text="식  (한 줄에 하나)").pack(anchor="w")
        self.txt = tk.Text(left, width=34, height=12, font=(MONO, 11),
                           relief="solid", borderwidth=1, wrap="none")
        self.txt.pack(fill="both", expand=True, pady=(2, 8))
        self.txt.insert("1.0", DEFAULT_EQ)
        self.txt.bind("<Control-Return>", lambda e: (self.build(), "break")[1])

        row = ttk.Frame(left)
        row.pack(fill="x")
        ttk.Button(row, text="만들기", command=self.build).pack(side="left")
        ttk.Button(row, text="PNG 저장", command=self.export).pack(side="left", padx=6)
        ttk.Button(row, text="예제", command=self.examples).pack(side="left")

        ttk.Label(left, justify="left", foreground=MUTED, font=(MONO, 9),
                  text=("문법\n"
                        "  AND  A B,  A*B,  A&B\n"
                        "  OR   A + B,  A|B\n"
                        "  XOR  A ^ B\n"
                        "  NOT  A'   ~A   !A\n"
                        "플립플롭\n"
                        "  D형  DA = ...   (A* = ... 도 됨)\n"
                        "  T형  TA = ...\n"
                        "  JK형 JA = ...  /  KA = ...\n"
                        "그 밖의 좌변은 출력식입니다.\n"
                        "출력식에 입력 변수가 들어가면 Mealy,\n"
                        "아니면 Moore로 그립니다.\n"
                        "Ctrl+Enter 로도 다시 그립니다.")
                  ).pack(anchor="w", pady=(10, 0))

        right = ttk.Frame(self, padding=(0, 10, 10, 10))
        right.pack(side="left", fill="both", expand=True)
        nb = ttk.Notebook(right)
        nb.pack(fill="both", expand=True)

        gf = ttk.Frame(nb)
        nb.add(gf, text="상태 천이도")
        self.canvas = tk.Canvas(gf, bg=PAPER, highlightthickness=1,
                                highlightbackground=LINE)
        xs = ttk.Scrollbar(gf, orient="horizontal", command=self.canvas.xview)
        ys = ttk.Scrollbar(gf, orient="vertical", command=self.canvas.yview)
        self.canvas.configure(xscrollcommand=xs.set, yscrollcommand=ys.set)
        self.canvas.grid(row=0, column=0, sticky="nsew")
        ys.grid(row=0, column=1, sticky="ns")
        xs.grid(row=1, column=0, sticky="ew")
        gf.rowconfigure(0, weight=1)
        gf.columnconfigure(0, weight=1)

        tf = ttk.Frame(nb)
        nb.add(tf, text="상태표")
        self.table = tk.Text(tf, font=(MONO, 11), wrap="none", relief="flat")
        ts = ttk.Scrollbar(tf, command=self.table.yview)
        self.table.configure(yscrollcommand=ts.set)
        self.table.pack(side="left", fill="both", expand=True)
        ts.pack(side="right", fill="y")

        self.status = ttk.Label(self, text="", foreground=MUTED, anchor="w")
        self.status.place(relx=0, rely=1, y=-18, relwidth=1, x=12)

        self.build()

    def examples(self):
        w = tk.Toplevel(self)
        w.title("예제")
        w.geometry("520x440")
        for name, sv, iv, stt, eq in EXAMPLES:
            f = ttk.Frame(w, padding=8)
            f.pack(fill="x")
            ttk.Label(f, text=name, font=(MONO, 10, "bold")).pack(anchor="w")
            ttk.Label(f, text=eq, foreground=MUTED, font=(MONO, 9),
                      justify="left").pack(anchor="w")

            def use(sv=sv, iv=iv, stt=stt, eq=eq, w=w):
                self.v_state.set(sv)
                self.v_in.set(iv)
                self.v_start.set(stt)
                self.txt.delete("1.0", "end")
                self.txt.insert("1.0", eq)
                w.destroy()
                self.build()

            ttk.Button(f, text="이 예제 쓰기", command=use).pack(anchor="w", pady=2)
            ttk.Separator(w).pack(fill="x")

    def build(self):
        try:
            self.fsm = FSM(self.v_state.get(), self.v_in.get(),
                           self.txt.get("1.0", "end"), self.v_start.get())
        except EqError as e:
            self.status.configure(text="⚠ %s" % e, foreground=DANGER)
            messagebox.showerror("식을 읽을 수 없습니다", str(e))
            return
        except Exception as e:
            self.status.configure(text="⚠ %s" % e, foreground=DANGER)
            return

        f = self.fsm
        W, H = graph_size(f)
        self.canvas.delete("all")
        draw_graph(TkBE(self.canvas), f, W, H)
        self.canvas.configure(scrollregion=(0, 0, W, H))

        self.table.delete("1.0", "end")
        self.table.insert("1.0", f.table_text())
        un = len(f.states) - len(f.reach)
        self.status.configure(
            text="상태 %d개 · 입력 조합 %d개 · %s%s"
                 % (len(f.states), len(f.ins), "Mealy" if f.mealy else "Moore",
                    " · 도달 불가 %d개" % un if un else ""),
            foreground=MUTED)

    def export(self):
        if not self.fsm:
            return
        if not HAS_PIL:
            messagebox.showinfo("Pillow가 필요합니다",
                                "PNG로 저장하려면 설치해 주세요.\n\n    pip install pillow")
            return
        p = filedialog.asksaveasfilename(defaultextension=".png",
                                         filetypes=[("PNG 이미지", "*.png")],
                                         initialfile="state_graph.png")
        if not p:
            return
        render_png(self.fsm, p)
        messagebox.showinfo("저장 완료", p)


if __name__ == "__main__":
    App().mainloop()