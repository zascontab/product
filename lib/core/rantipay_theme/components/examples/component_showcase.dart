import 'package:flutter/material.dart';
import '../base/index.dart';
import '../../ranti_colors.dart';
import '../../design_tokens.dart';

/// Página de demostración de componentes base de RantiPay
/// Útil para testing visual y desarrollo
class ComponentShowcase extends StatelessWidget {
  const ComponentShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RantiPay Component Showcase'),
        backgroundColor: RantiColors.getSurface(context),
      ),
      backgroundColor: RantiColors.getBackground(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          RantiDesignTokens.getResponsiveSpacing(context, RantiDesignTokens.spaceL),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              'Botones',
              _buildButtonShowcase(context),
            ),
            SizedBox(height: RantiDesignTokens.spaceXL),
            _buildSection(
              context,
              'Tarjetas',
              _buildCardShowcase(context),
            ),
            SizedBox(height: RantiDesignTokens.spaceXL),
            _buildSection(
              context,
              'Componentes TikTok',
              _buildTikTokShowcase(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: RantiDesignTokens.getResponsiveFontSize(
              context,
              RantiDesignTokens.fontSizeTitle,
            ),
            fontWeight: RantiDesignTokens.weightBold,
            color: RantiColors.getTextPrimary(context),
          ),
        ),
        SizedBox(height: RantiDesignTokens.spaceM),
        content,
      ],
    );
  }

  Widget _buildButtonShowcase(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Botones primarios
        _buildButtonRow(
          context,
          'Primarios',
          [
            RantiButton.primary(
              onPressed: () {},
              text: 'Small',
              size: RantiButtonSize.small,
            ),
            RantiButton.primary(
              onPressed: () {},
              text: 'Medium',
              size: RantiButtonSize.medium,
            ),
            RantiButton.primary(
              onPressed: () {},
              text: 'Large',
              size: RantiButtonSize.large,
            ),
          ],
        ),
        
        SizedBox(height: RantiDesignTokens.spaceM),
        
        // Botones secundarios
        _buildButtonRow(
          context,
          'Secundarios',
          [
            RantiButton.secondary(
              onPressed: () {},
              text: 'Secundario',
              leadingIcon: Icons.star,
            ),
            RantiButton.text(
              onPressed: () {},
              text: 'Texto',
              trailingIcon: Icons.arrow_forward,
            ),
            RantiButton(
              onPressed: () {},
              text: 'Delineado',
              variant: RantiButtonVariant.outlined,
            ),
          ],
        ),
        
        SizedBox(height: RantiDesignTokens.spaceM),
        
        // Botones de estado
        _buildButtonRow(
          context,
          'Estados',
          [
            RantiButton(
              onPressed: () {},
              text: 'Peligro',
              variant: RantiButtonVariant.danger,
            ),
            RantiButton(
              onPressed: () {},
              text: 'Éxito',
              variant: RantiButtonVariant.success,
            ),
            const RantiButton(
              onPressed: null,
              text: 'Deshabilitado',
            ),
          ],
        ),
        
        SizedBox(height: RantiDesignTokens.spaceM),
        
        // Botón con loading
        _buildButtonRow(
          context,
          'Loading',
          [
            RantiButton.primary(
              onPressed: () {},
              text: 'Cargando',
              isLoading: true,
            ),
            RantiButton.primary(
              onPressed: () {},
              text: 'Ancho completo',
              width: double.infinity,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButtonRow(BuildContext context, String label, List<Widget> buttons) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: RantiDesignTokens.fontSizeL,
            fontWeight: RantiDesignTokens.weightMedium,
            color: RantiColors.getTextSecondary(context),
          ),
        ),
        SizedBox(height: RantiDesignTokens.spaceS),
        Wrap(
          spacing: RantiDesignTokens.spaceM,
          runSpacing: RantiDesignTokens.spaceS,
          children: buttons,
        ),
      ],
    );
  }

  Widget _buildCardShowcase(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tarjetas básicas
        Row(
          children: [
            Expanded(
              child: RantiCard.surface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tarjeta Superficie',
                      style: TextStyle(
                        fontSize: RantiDesignTokens.fontSizeL,
                        fontWeight: RantiDesignTokens.weightSemiBold,
                        color: RantiColors.getTextPrimary(context),
                      ),
                    ),
                    SizedBox(height: RantiDesignTokens.spaceS),
                    Text(
                      'Esta es una tarjeta básica con fondo de superficie.',
                      style: TextStyle(
                        fontSize: RantiDesignTokens.fontSizeM,
                        color: RantiColors.getTextSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: RantiDesignTokens.spaceM),
            Expanded(
              child: RantiCard.elevated(
                elevation: RantiCardElevation.medium,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tarjeta Elevada',
                      style: TextStyle(
                        fontSize: RantiDesignTokens.fontSizeL,
                        fontWeight: RantiDesignTokens.weightSemiBold,
                        color: RantiColors.getTextPrimary(context),
                      ),
                    ),
                    SizedBox(height: RantiDesignTokens.spaceS),
                    Text(
                      'Esta tarjeta tiene sombra y elevación.',
                      style: TextStyle(
                        fontSize: RantiDesignTokens.fontSizeM,
                        color: RantiColors.getTextSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: RantiDesignTokens.spaceM),
        
        // Tarjeta interactiva
        RantiCard.outlined(
          onTap: () {
            debugPrint('Tarjeta tocada!');
          },
          child: Row(
            children: [
              Icon(
                Icons.touch_app,
                color: RantiColors.getPrimary(context),
                size: RantiDesignTokens.iconSizeL,
              ),
              SizedBox(width: RantiDesignTokens.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tarjeta Interactiva',
                      style: TextStyle(
                        fontSize: RantiDesignTokens.fontSizeL,
                        fontWeight: RantiDesignTokens.weightSemiBold,
                        color: RantiColors.getTextPrimary(context),
                      ),
                    ),
                    SizedBox(height: RantiDesignTokens.spaceXS),
                    Text(
                      'Toca esta tarjeta para ver la interacción.',
                      style: TextStyle(
                        fontSize: RantiDesignTokens.fontSizeM,
                        color: RantiColors.getTextSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: RantiColors.getTextTertiary(context),
                size: RantiDesignTokens.iconSizeM,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTikTokShowcase(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(RantiDesignTokens.spaceL),
      decoration: BoxDecoration(
        color: RantiColors.tiktokBackground,
        borderRadius: BorderRadius.circular(RantiDesignTokens.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Componentes TikTok',
            style: TextStyle(
              fontSize: RantiDesignTokens.fontSizeL,
              fontWeight: RantiDesignTokens.weightSemiBold,
              color: RantiColors.tiktokText,
            ),
          ),
          SizedBox(height: RantiDesignTokens.spaceM),
          
          // Botones TikTok
          Row(
            children: [
              RantiButton.tiktok(
                onPressed: () {},
                text: 'Me gusta',
                leadingIcon: Icons.favorite,
              ),
              SizedBox(width: RantiDesignTokens.spaceM),
              RantiButton.tiktok(
                onPressed: () {},
                text: 'Compartir',
                leadingIcon: Icons.share,
              ),
            ],
          ),
          
          SizedBox(height: RantiDesignTokens.spaceM),
          
          // Tarjeta TikTok
          RantiCard.tiktok(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: RantiColors.tiktokAction.withAlpha(128),
                  child: Icon(
                    Icons.person,
                    color: RantiColors.tiktokText,
                  ),
                ),
                SizedBox(width: RantiDesignTokens.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '@usuario_rantipay',
                        style: TextStyle(
                          fontSize: RantiDesignTokens.fontSizeL,
                          fontWeight: RantiDesignTokens.weightSemiBold,
                          color: RantiColors.tiktokText,
                        ),
                      ),
                      Text(
                        'Creador de contenido financiero',
                        style: TextStyle(
                          fontSize: RantiDesignTokens.fontSizeM,
                          color: RantiColors.tiktokTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.verified,
                  color: RantiColors.tiktokAction,
                  size: RantiDesignTokens.iconSizeM,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}