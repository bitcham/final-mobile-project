part of '../main_tab_screen.dart';

class _CinerateBottomNav extends StatelessWidget {
  const _CinerateBottomNav({
    required this.selectedTab,
    required this.onSelected,
  });

  final _MainTab selectedTab;
  final ValueChanged<_MainTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(18, 0, 18, 8),
      child: SizedBox(
        height: 66,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: palette.textPrimary.withValues(alpha: 0.08),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomNavItem(
                tab: _MainTab.home,
                icon: CupertinoIcons.house_fill,
                label: 'HOME',
                selected: selectedTab == _MainTab.home,
                onSelected: onSelected,
              ),
              _BottomNavItem(
                tab: _MainTab.search,
                icon: CupertinoIcons.search,
                label: 'SEARCH',
                selected: selectedTab == _MainTab.search,
                onSelected: onSelected,
              ),
              _BottomNavItem(
                tab: _MainTab.watchlist,
                icon: CupertinoIcons.heart_fill,
                label: 'WATCHLIST',
                selected: selectedTab == _MainTab.watchlist,
                onSelected: onSelected,
              ),
              _BottomNavItem(
                tab: _MainTab.settings,
                icon: CupertinoIcons.gear_solid,
                label: 'SETTINGS',
                selected: selectedTab == _MainTab.settings,
                onSelected: onSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.tab,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final _MainTab tab;
  final IconData icon;
  final String label;
  final bool selected;
  final ValueChanged<_MainTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    final color = selected ? palette.primary : palette.textPrimary;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(58, 58),
      onPressed: () => onSelected(tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 82,
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: selected
              ? palette.primary.withValues(alpha: 0.12)
              : CupertinoColors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 7),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
