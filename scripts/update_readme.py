#!/usr/bin/env python3
"""projects/<작업명>/ 의 note.md + HDL 모듈 포트 + 최근 커밋 정보를 모아 루트 README.md 를 생성합니다."""
import re
import subprocess
import sys
from pathlib import Path

try:  # Windows 콘솔(cp949/cp1252)에서 한글 출력 시 에러 방지
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

ROOT_DIR = Path(__file__).resolve().parent.parent
PROJECTS_DIR = ROOT_DIR / "projects"
README_PATH = ROOT_DIR / "README.md"

VERILOG_EXT = {".v", ".sv"}
VHDL_EXT = {".vhd", ".vhdl"}
HDL_EXT = VERILOG_EXT | VHDL_EXT
PLACEHOLDER_SUMMARY = "(한 줄 요약을 작성하세요)"


def cell(text: str) -> str:
    """마크다운 표 셀 안에서 깨지지 않도록 | 와 줄바꿈을 처리합니다."""
    return str(text).replace("|", "\\|").replace("\n", " ")


def get_last_commit_info(path: Path) -> str:
    try:
        result = subprocess.run(
            ["git", "log", "-1", "--format=%cs", "--", str(path)],
            cwd=ROOT_DIR, capture_output=True, text=True, check=True,
        )
        return result.stdout.strip() or "커밋 전"
    except Exception:
        return "-"


def parse_note_md(note_path: Path, default_name: str):
    if not note_path.exists():
        return default_name, "-", "_`note.md`가 아직 작성되지 않았습니다._"

    title, summary, body = default_name, "-", []
    for line in note_path.read_text(encoding="utf-8").splitlines():
        s = line.strip()
        if s.startswith("# ") and title == default_name:
            title = s[2:].strip()
        elif s.startswith(">") and summary == "-":
            summary = s.lstrip(">").strip() or "-"
        else:
            body.append(line)
    if summary == PLACEHOLDER_SUMMARY:
        summary = "-"
    # 템플릿 그대로(빈 항목만)인 노트는 '없음'으로 표시
    meaningful = [l for l in body if l.strip() and l.strip() not in {"-", "- "} and not l.strip().startswith("#")]
    text = "\n".join(body).strip()
    return title, summary, (text if meaningful else "_상세 노트 없음_")


# ---------------------------------------------------------------- Verilog / SystemVerilog
def strip_comments_verilog(src: str) -> str:
    src = re.sub(r"/\*.*?\*/", " ", src, flags=re.DOTALL)
    return re.sub(r"//[^\n]*", "", src)


def skip_balanced(text: str, start: int) -> int:
    """text[start] == '(' 일 때 짝이 맞는 ')' 다음 인덱스를 반환"""
    depth = 0
    for i in range(start, len(text)):
        if text[i] == "(":
            depth += 1
        elif text[i] == ")":
            depth -= 1
            if depth == 0:
                return i + 1
    return len(text)


TYPE_WORDS = {"wire", "reg", "logic", "signed", "unsigned", "var", "tri", "bit",
              "integer", "int", "byte", "shortint", "longint", "wand", "wor", "uwire"}
DIR_RE = re.compile(r"\b(input|output|inout)\b")
IDENT_RE = re.compile(r"[A-Za-z_][A-Za-z0-9_$]*")


def parse_port_segment(direction: str, seg: str):
    seg = seg.strip().rstrip(")").strip()
    width = "1"
    m = re.match(r"^((?:\s*\b\w+\b)*?)\s*(\[[^\]]+\](?:\s*\[[^\]]+\])*)", seg)
    if m and all(w in TYPE_WORDS for w in m.group(1).split()):
        width = re.sub(r"\s+", "", m.group(2))
        seg = seg[m.end():]
    ports = []
    for item in seg.split(","):
        item = re.sub(r"\[[^\]]*\]", " ", item.split("=")[0])
        names = [t for t in IDENT_RE.findall(item) if t not in TYPE_WORDS]
        if names:
            ports.append((direction, width, names[-1]))  # 사용자 정의 타입이 앞에 오면 마지막이 포트명
    return ports


def parse_verilog(text: str):
    text = strip_comments_verilog(text)
    modules = []
    for m in re.finditer(r"\b(?:module|macromodule)\s+(?:automatic\s+|static\s+)?([A-Za-z_]\w*)", text):
        end = re.search(r"\bendmodule\b", text[m.end():])
        body = text[m.end(): m.end() + end.start()] if end else text[m.end():]
        # 파라미터 블록 #( ... ) 제거
        pm = re.match(r"\s*(?:import\s+[^;]*;\s*)*#\s*\(", body)
        if pm:
            body = body[skip_balanced(body, pm.end() - 1):]
        ports = []
        dirs = list(DIR_RE.finditer(body))
        for i, d in enumerate(dirs):
            stop = dirs[i + 1].start() if i + 1 < len(dirs) else len(body)
            seg = body[d.end():stop]
            semi = seg.find(";")
            if semi != -1:
                seg = seg[:semi]
            ports.extend(parse_port_segment(d.group(1), seg))
        modules.append((m.group(1), ports))
    return modules


# ---------------------------------------------------------------- VHDL
def parse_vhdl(text: str):
    text = re.sub(r"--[^\n]*", "", text)
    modules = []
    for m in re.finditer(r"\bentity\s+(\w+)\s+is\b", text, flags=re.IGNORECASE):
        rest = text[m.end():]
        end = re.search(r"\bend\b", rest, flags=re.IGNORECASE)
        pm = re.search(r"\bport\s*\(", rest, flags=re.IGNORECASE)
        ports = []
        if pm and (not end or pm.start() < end.start()):
            block = rest[pm.end(): skip_balanced(rest, pm.end() - 1) - 1]
            for decl in block.split(";"):
                if ":" not in decl:
                    continue
                names, spec = decl.split(":", 1)
                dm = re.match(r"\s*(in|out|inout|buffer)\b(.*)", spec, flags=re.IGNORECASE | re.DOTALL)
                if not dm:
                    continue
                direction = {"in": "input", "out": "output", "inout": "inout", "buffer": "output"}[dm.group(1).lower()]
                rng = re.search(r"\(\s*(.+?)\s+(downto|to)\s+(.+?)\s*\)", dm.group(2), flags=re.IGNORECASE)
                width = f"[{rng.group(1)}:{rng.group(3)}]" if rng else "1"
                for n in names.split(","):
                    if n.strip():
                        ports.append((direction, width, n.strip()))
        modules.append((m.group(1), ports))
    return modules


def parse_hdl_modules(src_dir: Path):
    modules = []
    if not src_dir.exists():
        return modules
    for fp in sorted(src_dir.iterdir(), key=lambda p: p.name.lower()):
        if not fp.is_file() or fp.suffix.lower() not in HDL_EXT:
            continue
        content = fp.read_text(encoding="utf-8", errors="ignore")
        parsed = parse_verilog(content) if fp.suffix.lower() in VERILOG_EXT else parse_vhdl(content)
        for name, ports in parsed:
            modules.append({"file": fp.name, "module": name, "ports": ports})
    return modules


def list_files(d: Path, exts):
    if not d.exists():
        return []
    return sorted((f.name for f in d.iterdir() if f.is_file() and f.suffix.lower() in exts), key=str.lower)


def anchor(text: str) -> str:
    """GitHub 헤더 앵커 규칙(대략): 소문자, 공백→-, 영숫자/한글/-/_ 외 제거"""
    a = text.strip().lower().replace(" ", "-")
    return re.sub(r"[^\w\-가-힣]", "", a)


def build_readme():
    PROJECTS_DIR.mkdir(parents=True, exist_ok=True)
    project_dirs = sorted(
        (d for d in PROJECTS_DIR.iterdir() if d.is_dir() and not d.name.startswith(".")),
        key=lambda p: p.name.lower(),
    )

    md = [
        "# FPGA & Vivado 작업 아카이브\n",
        "> 여러 PC(Vivado 2025.2 / 2026.1)에서 동기화되는 HDL 작업 저장소입니다. "
        "푸시하면 각 프로젝트의 `note.md`와 RTL 모듈 구조가 아래에 자동으로 정리됩니다. "
        "(이 파일은 `scripts/update_readme.py`가 생성하므로 직접 수정하지 마세요.)\n",
        "## 사용법\n",
        "```tcl",
        "# Vivado Tcl Console (어느 버전이든)",
        "cd C:/경로/리포지토리/projects/<작업명>",
        "source ../../scripts/create_proj.tcl",
        "```\n",
        "## 전체 작업 목록\n",
        "| 프로젝트 | 한 줄 요약 | 포함 모듈 | 최근 업데이트 |",
        "| :--- | :--- | :--- | :--- |",
    ]

    details = []
    for pdir in project_dirs:
        rel = f"projects/{pdir.name}"
        title, summary, note_body = parse_note_md(pdir / "note.md", pdir.name)
        modules = parse_hdl_modules(pdir / "src")
        last = get_last_commit_info(pdir)
        mods = ", ".join(f"`{m['module']}`" for m in modules) or "-"
        heading = f"{title} ({pdir.name})" if title != pdir.name else title
        md.append(f"| [**{cell(title)}**](#{anchor(heading)}) | {cell(summary)} | {mods} | {last} |")
        details.append(dict(
            rel=rel, heading=heading, summary=summary, note_body=note_body,
            modules=modules, last=last,
            sim=list_files(pdir / "sim", HDL_EXT), xdc=list_files(pdir / "xdc", {".xdc"}),
            ip=list_files(pdir / "ip", {".xci"}),
        ))

    if not project_dirs:
        md.append("| _등록된 프로젝트 없음_ | `projects/<작업명>/` 폴더를 추가해 주세요. | - | - |")

    md.append("\n## 프로젝트별 상세 노트 및 모듈 명세\n")
    for it in details:
        md.append(f"### {it['heading']}\n")
        md.append(f"- **폴더**: [`{it['rel']}`]({it['rel']}) · [note.md]({it['rel']}/note.md)")
        md.append(f"- **요약**: {it['summary']}")
        md.append(f"- **최근 업데이트**: {it['last']}")
        if it["sim"]:
            md.append("- **시뮬레이션 파일**: " + ", ".join(f"`{f}`" for f in it["sim"]))
        if it["xdc"]:
            md.append("- **제약조건(XDC)**: " + ", ".join(f"`{f}`" for f in it["xdc"]))
        if it["ip"]:
            md.append("- **IP 코어**: " + ", ".join(f"`{f}`" for f in it["ip"]))
        md.append("")
        md.append("#### 작업 노트\n")
        md.append(it["note_body"])
        md.append("")
        if it["modules"]:
            md.append("<details><summary>RTL 모듈 및 포트 요약</summary>\n")
            md.append("| 소스 파일 | 모듈명 | 방향 | 비트폭 | 포트명 |")
            md.append("| :--- | :--- | :--- | :--- | :--- |")
            for mod in it["modules"]:
                if mod["ports"]:
                    for i, (d, w, n) in enumerate(mod["ports"]):
                        f = f"`{cell(mod['file'])}`" if i == 0 else ""
                        m = f"**`{mod['module']}`**" if i == 0 else ""
                        md.append(f"| {f} | {m} | `{d}` | `{cell(w)}` | `{n}` |")
                else:
                    md.append(f"| `{cell(mod['file'])}` | **`{mod['module']}`** | - | - | _포트 없음 (테스트벤치 등)_ |")
            md.append("\n</details>\n")

    README_PATH.write_text("\n".join(md) + "\n", encoding="utf-8")
    print(f"README.md 업데이트 완료 ({len(project_dirs)}개 프로젝트)")


if __name__ == "__main__":
    build_readme()
